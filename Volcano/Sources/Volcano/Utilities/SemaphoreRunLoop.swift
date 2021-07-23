//
//  SemaphoreRunLoop.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2021.
//

import CVulkan
import Foundation

internal class TimelineSemaphoreSet {
    let device: Device
    var semaphores: Set<TimelineSemaphore> = []
    let lock = NSRecursiveLock()

    init(device: Device) {
        self.device = device
    }

    func add(semaphore: TimelineSemaphore) {
        add(semaphores: [semaphore])
    }

    func add(semaphores: Set<TimelineSemaphore>) {
        lock.lock()
        defer { lock.unlock() }

        self.semaphores.formUnion(semaphores)
    }

    func remove(semaphore: TimelineSemaphore) {
        remove(semaphores: [semaphore])
    }

    func remove(semaphores: Set<TimelineSemaphore>) {
        lock.lock()
        defer { lock.unlock() }

        self.semaphores.subtract(semaphores)
    }

    func modify(remove semaphoresToRemove: Set<TimelineSemaphore>, add semaphoresToAdd: Set<TimelineSemaphore>) {
        lock.lock()
        defer { lock.unlock() }

        semaphores.subtract(semaphoresToRemove)
        semaphores.formUnion(semaphoresToAdd)
    }

    func wait(forOne: Bool = true, timeout: UInt64 = .max) throws -> [TimelineSemaphore] {
        let currentSemaphores: [TimelineSemaphore]
        var values: [UInt64]

        (currentSemaphores, values) = try {
            lock.lock()
            defer { lock.unlock() }

            assert(semaphores.isEmpty == false)
            
            let values = try semaphores.map {
                try $0.value + 1
            }

            return (Array(semaphores), values)
        }()

        try currentSemaphores.withUnsafeBufferPointer { currentSemaphores in
            try values.withUnsafeBufferPointer { values in
                var info = VkSemaphoreWaitInfo()
                try vulkanInvoke {
                    vkWaitSemaphores(device.handle, &info, timeout)
                }
            }
        }

        return try currentSemaphores
            .enumerated()
            .filter {
                try $0.element.value != values[$0.offset]
            }
            .map { $0.element }
    }
}

public extension SemaphoreRunLoop {
    class Source: Hashable {
        public func hash(into hasher: inout Hasher) {
            semaphore.hash(into: &hasher)
            ObjectIdentifier(self).hash(into: &hasher)
        }

        public static func == (lhs: SemaphoreRunLoop.Source, rhs: SemaphoreRunLoop.Source) -> Bool {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }

        fileprivate weak var runLoop: SemaphoreRunLoop? = nil
        public let semaphore: TimelineSemaphore

        internal func perform() throws {}

        public init(with semaphore: TimelineSemaphore) {
            self.semaphore = semaphore
        }
        
        public func invalildate() throws {
            try runLoop?.remove(source: self)
        }
    }

    class SourceCallback: Source {
        public typealias Callback = () -> ()

        public let callback: Callback

        public init(with semaphore: TimelineSemaphore, callback: @escaping Callback) {
            self.callback = callback

            super.init(with: semaphore)
        }

        override func perform() throws {
            callback()
        }
    }

    class SourceContinuation: Source {
        public typealias Continuation = UnsafeContinuation<Void, Never>
        public let continuation: Continuation

        public init(with semaphore: TimelineSemaphore, continuation: Continuation) {
            self.continuation = continuation

            super.init(with: semaphore)
        }

        override func perform() throws {
            continuation.resume()
        }
    }
}

public final class SemaphoreRunLoop {
    internal let lock = NSRecursiveLock()
    internal let wakeUpSemaphore: TimelineSemaphore!
    internal var semaphoreSet: TimelineSemaphoreSet
    internal var semaphoreToSource: [TimelineSemaphore: Source] = [:]

    internal var sourcesToAdd: Set<Source> = []
    internal var sourcesToRemove: Set<Source> = []

    internal var _isStopped: Bool = false
    internal var isStopped: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }

            return _isStopped
        }
        set {
            lock.lock()
            defer { lock.unlock() }

            _isStopped = newValue
        }
    }

    deinit {
        lock.lock()
        defer { lock.unlock() }

        do {
            try wakeUpSemaphore.signal(with: 1)
        } catch {
            fatalError("Got vulkan error while trying to signal the wakeUpSemaphore: \(error)")
        }
    }

    public init(device: Device) throws {
        wakeUpSemaphore = nil
        semaphoreSet = TimelineSemaphoreSet(device: device)
        semaphoreSet.add(semaphore: wakeUpSemaphore)
    }

    public func add(source: Source) throws {
        try add(sources: [source])
    }

    public func add(sources: [Source]) throws {
        lock.lock()
        defer { lock.unlock() }

        if _isStopped == false {
            try wakeUpSemaphore.signal(with: 1)
        }
    }

    public func remove(source: Source) throws {
        try remove(sources: [source])
    }

    public func remove(sources: [Source]) throws {
        lock.lock()
        defer { lock.unlock() }

        if _isStopped == false {
            try wakeUpSemaphore.signal(with: 1)
        }
    }

    public func wakeUp() throws {
        lock.lock()
        defer { lock.unlock() }
        
        try wakeUpSemaphore.signal(with: 1)
    }

    public func stop() throws {
        lock.lock()
        defer { lock.unlock() }

        _isStopped = true

        try wakeUpSemaphore.signal(with: 1)
    }

    public func run(before limitDate: Date) throws -> Bool {
        lock.lock()

        let semaphoresToRemove = Set(sourcesToRemove.map { $0.semaphore })
        let sempahoresToAdd = Set(sourcesToAdd.map { $0.semaphore })
        semaphoreSet.modify(remove: semaphoresToRemove, add: sempahoresToAdd)

        sourcesToRemove.forEach {
            semaphoreToSource.removeValue(forKey: $0.semaphore)
        }

        sourcesToAdd.forEach {
            semaphoreToSource[$0.semaphore] = $0
        }

        sourcesToRemove.removeAll()
        sourcesToAdd.removeAll()

        lock.unlock()

        if isStopped {
            return false
        }

        let timeInterval = limitDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate

        let timeout: UInt64

        if timeInterval <= 0 {
            timeout = 0
        } else if timeInterval * 1000000000 < TimeInterval(UInt64.max) {
            timeout = UInt64(timeInterval) * 1000000000
        } else {
            timeout = .max
        }

        let signalledSemaphores = try semaphoreSet.wait(forOne: true, timeout: timeout)
        try signalledSemaphores.map { semaphoreToSource[$0]! }
            .forEach {
                try $0.perform()
            }
        return true
    }
}

public actor SemaphoreWatcher {
    private var thread: Thread
    public let runLoop: SemaphoreRunLoop
    public private(set) var sources: Set<SemaphoreRunLoop.Source> = []

    public init(device: Device) throws {
        let runLoop = try SemaphoreRunLoop(device: device)
        
        thread = Thread {
            do {
                repeat {
                    _ = try runLoop.run(before: .distantFuture)

                    if runLoop.isStopped {
                        break
                    }
                } while true
            } catch {
                fatalError("Got vulkan error while running the SemaphoreRunLoop: \(error)")
            }
        }

        self.runLoop = runLoop

        thread.start()
    }

    public func add(semaphore: TimelineSemaphore, callback: @escaping SemaphoreRunLoop.SourceCallback.Callback) throws -> SemaphoreRunLoop.SourceCallback {
        let source = SemaphoreRunLoop.SourceCallback(with: semaphore, callback: callback)
        sources.insert(source)

        try runLoop.add(source: source)

        return source
    }

    public func add(semaphore: TimelineSemaphore, continuation: SemaphoreRunLoop.SourceContinuation.Continuation) throws -> SemaphoreRunLoop.SourceContinuation {
        let source = SemaphoreRunLoop.SourceContinuation(with: semaphore, continuation: continuation)
        sources.insert(source)

        try runLoop.add(source: source)

        return source
    }

    public func remove(semaphore: Semaphore) throws {
        let sources = self.sources.filter { $0.semaphore === semaphore }
        
        try runLoop.remove(sources: Array(sources))

        self.sources.subtract(sources)
    }
}
