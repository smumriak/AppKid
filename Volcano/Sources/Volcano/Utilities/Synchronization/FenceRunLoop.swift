//
//  FenceRunLoop.swift
//  Volcano
//
//  Created by Serhii Mumriak on 26.09.2021.
//

import CVulkan
import Foundation

internal class FenceSet {
    let device: Device
    var fences: Set<Fence> = []
    let lock = NSRecursiveLock()

    init(device: Device) {
        fatalError("WORK IN PROGRESS, DO NOT USE")
        self.device = device
    }

    func add(fence: Fence) {
        lock.synchronized {
            _ = fences.insert(fence)
        }
    }

    func add(fences: Set<Fence>) {
        lock.synchronized {
            self.fences.formUnion(fences)
        }
    }

    func remove(fence: Fence) {
        lock.synchronized {
            _ = fences.remove(fence)
        }
    }

    func remove(fences: Set<Fence>) {
        lock.synchronized {
            self.fences.subtract(fences)
        }
    }

    func modify(remove fencesToRemove: Set<Fence>, add fencesToAdd: Set<Fence>) {
        lock.synchronized {
            fences.subtract(fencesToRemove)
            fences.formUnion(fencesToAdd)
        }
    }

    func wait(forOne: Bool = true, timeout: UInt64 = .max) throws -> [Fence] {
        var currentFences: [Fence] = []
    
        lock.synchronized {
            currentFences.append(contentsOf: fences)
        }
        
        try device.wait(for: currentFences, waitForAll: !forOne, timeout: timeout)

        return try currentFences
            .filter { try $0.isSignaled }
    }
}

public extension FenceRunLoop {
    class Source: Hashable {
        internal let waitValue: UInt64
        public func hash(into hasher: inout Hasher) {
            fence.hash(into: &hasher)
            ObjectIdentifier(self).hash(into: &hasher)
        }

        public static func == (lhs: FenceRunLoop.Source, rhs: FenceRunLoop.Source) -> Bool {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }

        fileprivate weak var runLoop: FenceRunLoop? = nil
        public let fence: Fence

        internal func perform() throws {}

        public init(with fence: Fence, waitValue: UInt64) {
            self.fence = fence
            self.waitValue = waitValue
        }
        
        public func invalildate() throws {
            try runLoop?.remove(source: self)
        }
    }

    class SourceCallback: Source {
        public typealias Callback = () -> ()

        public let callback: Callback

        public init(with fence: Fence, waitValue: UInt64, callback: @escaping Callback) {
            self.callback = callback

            super.init(with: fence, waitValue: waitValue)
        }

        override func perform() throws {
            callback()
        }
    }

    class ContinuationSource: Source {
        public typealias Continuation = UnsafeContinuation<Void, Never>
        public let continuation: Continuation

        public init(with fence: Fence, waitValue: UInt64, continuation: Continuation) {
            self.continuation = continuation

            super.init(with: fence, waitValue: waitValue)
        }

        override func perform() throws {
            continuation.resume()
        }
    }

    class ThrowingContinuationSource: Source {
        public typealias Continuation = UnsafeContinuation<Void, Error>
        public let continuation: Continuation

        public init(with fence: Fence, waitValue: UInt64, continuation: Continuation) {
            self.continuation = continuation

            super.init(with: fence, waitValue: waitValue)
        }

        override func perform() throws {
            continuation.resume()
        }
    }
}

internal protocol FenceRunLoopDelegate: AnyObject {
    func removeSignaledSources(_ sources: Set<FenceRunLoop.Source>)
}
    
public final class FenceRunLoop {
    internal let lock = NSRecursiveLock()
    internal let wakeUpFence: Fence
    internal var fenceSet: FenceSet
    internal var fenceToSource: [Fence: Source] = [:]

    internal var sourcesToAdd: Set<Source> = []
    internal var sourcesToRemove: Set<Source> = []
    internal weak var delegate: FenceRunLoopDelegate?

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
                fatalError("Got vulkan error while trying to signal the wakeUpFence: \(error)")
            }
        }
    }

    public init(device: Device) throws {
        wakeUpFence = try Fence(device: device)
        fenceSet = FenceSet(device: device)
        fenceSet.add(fence: wakeUpFence)
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
        // try lock.synchronized {
        //     try wakeUpFence.signal()
        // }
    }

    public func stop() throws {
        try lock.synchronized {
            _isStopped = true

            try wakeUp()
        }
    }

    public func run(before limitDate: Date) throws -> Bool {
        lock.synchronized {
            let fencesToRemove = Set(sourcesToRemove.map { $0.fence })
            let fencesToAdd = Set(sourcesToAdd.map { $0.fence })
            fenceSet.modify(remove: fencesToRemove, add: fencesToAdd)

            sourcesToRemove.forEach {
                fenceToSource.removeValue(forKey: $0.fence)
            }

            sourcesToAdd.forEach {
                fenceToSource[$0.fence] = $0
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
        } else if timeInterval * 1000000000 < TimeInterval(UInt64.max) {
            timeout = UInt64(timeInterval) * 1000000000
        } else {
            timeout = .max
        }

        let signalledFences = try fenceSet.wait(forOne: true, timeout: timeout)
        try signalledFences.compactMap { fenceToSource[$0] }
            .forEach {
                sourcesToRemove.insert($0)
                try $0.perform()
            }

        if signalledFences.contains(wakeUpFence) {
            fenceSet.modify(remove: [wakeUpFence], add: [wakeUpFence])
        }

        delegate?.removeSignaledSources(sourcesToRemove)

        return true
    }
}
