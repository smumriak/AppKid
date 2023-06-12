//
//  SemaphoreRunLoop.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2021.
//

import Foundation
import TinyFoundation

internal final class TimelineSemaphoreSet {
    let device: Device
    var semaphores: Set<TimelineSemaphore> = []
    var semaphoresToWaitValues: [TimelineSemaphore: UInt64] = [:]
    let lock = RecursiveLock()

    init(device: Device) {
        self.device = device
    }

    func add(semaphore: TimelineSemaphore, waitValue: UInt64) {
        add(semaphoresWithWaitValues: [semaphore: waitValue])
    }

    func add(semaphoresWithWaitValues: [TimelineSemaphore: UInt64]) {
        lock.synchronized {
            semaphoresWithWaitValues.forEach {
                semaphoresToWaitValues[$0.key] = $0.value
                semaphores.insert($0.key)
            }
        }
    }

    func remove(semaphore: TimelineSemaphore) {
        remove(semaphores: [semaphore])
    }

    func remove(semaphores: Set<TimelineSemaphore>) {
        lock.synchronized {
            semaphores.forEach {
                semaphoresToWaitValues.removeValue(forKey: $0)
                self.semaphores.remove($0)
            }
        }
    }

    func modify(remove semaphoresToRemove: Set<TimelineSemaphore>, add semaphoresWithWaitValuesToAdd: [TimelineSemaphore: UInt64]) {
        lock.synchronized {
            semaphoresToRemove.forEach {
                semaphoresToWaitValues.removeValue(forKey: $0)
            }

            semaphores.subtract(semaphoresToRemove)
            semaphores.formUnion(semaphoresWithWaitValuesToAdd.keys)

            semaphoresWithWaitValuesToAdd.forEach {
                semaphoresToWaitValues[$0.key] = $0.value
            }
        }
    }

    func wait(forOne: Bool = true, timeout: UInt64 = .max) throws -> [TimelineSemaphore] {
        var currentSemaphores: [TimelineSemaphore] = []
        var values: [UInt64] = []

        lock.synchronized {
            currentSemaphores.reserveCapacity(semaphoresToWaitValues.count)
            values.reserveCapacity(semaphoresToWaitValues.count)

            semaphoresToWaitValues.forEach {
                currentSemaphores.append($0.key)
                values.append($0.value)
            }
        }
        
        try device.wait(for: currentSemaphores, values: values, waitForAll: !forOne, timeout: timeout)

        return try currentSemaphores
            .enumerated()
            .filter {
                try $0.element.value >= values[$0.offset]
            }
            .map { $0.element }
    }
}

public extension SemaphoreRunLoop {
    final class Source: Hashable {
        internal let waitValue: UInt64
        public func hash(into hasher: inout Hasher) {
            semaphore.hash(into: &hasher)
            ObjectIdentifier(self).hash(into: &hasher)
        }

        public static func == (lhs: SemaphoreRunLoop.Source, rhs: SemaphoreRunLoop.Source) -> Bool {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }

        fileprivate weak var runLoop: SemaphoreRunLoop? = nil
        public let semaphore: TimelineSemaphore
        public typealias Callback = () -> ()
        public typealias Continuation = UnsafeContinuation<Void, Never>
        public typealias ThrowingContinuation = UnsafeContinuation<Void, Error>

        internal enum Store {
            case callback(Callback)
            case continuation(Continuation)
            case throwingContinuation(ThrowingContinuation)

            func perform() throws {
                switch self {
                    case .callback(let value): value()
                    case .continuation(let value): value.resume()
                    case .throwingContinuation(let value): value.resume()
                }
            }
        }

        internal let store: Store

        public init(with semaphore: TimelineSemaphore, waitValue: UInt64, callback: @escaping Callback) {
            self.semaphore = semaphore
            self.waitValue = waitValue
            store = .callback(callback)
        }

        public init(with semaphore: TimelineSemaphore, waitValue: UInt64, continuation: Continuation) {
            self.semaphore = semaphore
            self.waitValue = waitValue
            store = .continuation(continuation)
        }

        public init(with semaphore: TimelineSemaphore, waitValue: UInt64, throwingContinuation: ThrowingContinuation) {
            self.semaphore = semaphore
            self.waitValue = waitValue
            store = .throwingContinuation(throwingContinuation)
        }
        
        public func invalildate() throws {
            try runLoop?.remove(source: self)
        }
    }
}

internal protocol SemaphoreRunLoopDelegate: AnyObject {
    func removeSignaledSources(_ sources: Set<SemaphoreRunLoop.Source>)
}
    
public final class SemaphoreRunLoop {
    internal let lock = RecursiveLock()
    internal let wakeUpSemaphore: TimelineSemaphore
    internal var semaphoreSet: TimelineSemaphoreSet
    internal var semaphoreToSource: [TimelineSemaphore: Source] = [:]

    internal var sourcesToAdd: Set<Source> = []
    internal var sourcesToRemove: Set<Source> = []
    internal weak var delegate: SemaphoreRunLoopDelegate?

    internal var _isStopped: Bool = false
    internal var isStopped: Bool {
        get {
            lock.synchronized { _isStopped }
        }
        set {
            lock.synchronized { _isStopped = newValue }
        }
    }

    deinit {
        lock.synchronized {
            do {
                try wakeUp()
            } catch {
                fatalError("Got vulkan error while trying to signal the wakeUpSemaphore: \(error)")
            }
        }
    }

    public init(device: Device) throws {
        wakeUpSemaphore = try TimelineSemaphore(device: device)
        semaphoreSet = TimelineSemaphoreSet(device: device)
        semaphoreSet.add(semaphore: wakeUpSemaphore, waitValue: 1)
    }

    public func add(source: Source) throws {
        try add(sources: [source])
    }

    public func add(sources: Set<Source>) throws {
        try lock.synchronized {
            sourcesToAdd.formUnion(sources)

            if _isStopped == false {
                try wakeUp()
            }
        }
    }

    public func remove(source: Source) throws {
        try remove(sources: [source])
    }

    public func remove(sources: Set<Source>) throws {
        try lock.synchronized {
            sourcesToRemove.formUnion(sources)

            if _isStopped == false {
                try wakeUp()
            }
        }
    }

    public func wakeUp() throws {
        try lock.synchronized {
            try wakeUpSemaphore.signal()
        }
    }

    public func stop() throws {
        try lock.synchronized {
            _isStopped = true

            try wakeUp()
        }
    }

    public func run(before limitDate: Date) throws -> Bool {
        lock.synchronized {
            let semaphoresToRemove = Set(sourcesToRemove.map { $0.semaphore })
            let sempahoresToAdd = Dictionary(uniqueKeysWithValues: sourcesToAdd.map { ($0.semaphore, $0.waitValue) })
            semaphoreSet.modify(remove: semaphoresToRemove, add: sempahoresToAdd)

            sourcesToRemove.forEach {
                semaphoreToSource.removeValue(forKey: $0.semaphore)
            }

            sourcesToAdd.forEach {
                semaphoreToSource[$0.semaphore] = $0
            }

            sourcesToRemove.removeAll()
            sourcesToAdd.removeAll()
        }

        if isStopped {
            return false
        }

        let timeInterval = limitDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate

        let timeout: UInt64

        if timeInterval <= 0 {
            timeout = 0
        } else if timeInterval * 1_000_000_000 < TimeInterval(UInt64.max) {
            timeout = UInt64(timeInterval) * 1_000_000_000
        } else {
            timeout = .max
        }

        let signalledSemaphores = try semaphoreSet.wait(forOne: true, timeout: timeout)
        try signalledSemaphores.compactMap { semaphoreToSource[$0] }
            .forEach {
                sourcesToRemove.insert($0)
                try $0.store.perform()
            }

        if signalledSemaphores.contains(wakeUpSemaphore) {
            try semaphoreSet.modify(remove: [wakeUpSemaphore], add: [wakeUpSemaphore: wakeUpSemaphore.value + 1])
        }

        delegate?.removeSignaledSources(sourcesToRemove)

        return true
    }
}
