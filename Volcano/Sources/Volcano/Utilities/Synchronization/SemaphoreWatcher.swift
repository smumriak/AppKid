//
//  SemaphoreWatcher.swift
//  Volcano
//
//  Created by Serhii Mumriak on 26.09.2021.
//

import Foundation
import TinyFoundation

public final class SemaphoreWatcher {
    private var thread: Thread
    private let lock = RecursiveLock()
    public let runLoop: SemaphoreRunLoop
    public private(set) var sources: Set<SemaphoreRunLoop.Source> = []

    deinit {
        do {
            try runLoop.stop()
        } catch {
            fatalError("Got vulkan error when tried to stop the SemaphoreRunLoop on deinit of SemaphoreWatcher: \(error)")
        }
    }

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

        thread.name = "SepahoreWatcher"
    }

    @discardableResult
    public func add(semaphore: TimelineSemaphore, waitValue: UInt64? = nil, callback: @escaping SemaphoreRunLoop.Source.Callback) throws -> SemaphoreRunLoop.Source {
        try lock.synchronized {
            let source = try SemaphoreRunLoop.Source(with: semaphore, waitValue: waitValue ?? semaphore.value, callback: callback)
            sources.insert(source)

            try runLoop.add(source: source)

            return source
        }
    }

    @discardableResult
    public func add(semaphore: TimelineSemaphore, waitValue: UInt64? = nil, continuation: SemaphoreRunLoop.Source.Continuation) throws -> SemaphoreRunLoop.Source {
        try lock.synchronized {
            let source = try SemaphoreRunLoop.Source(with: semaphore, waitValue: waitValue ?? semaphore.value, continuation: continuation)
            sources.insert(source)

            try runLoop.add(source: source)

            return source
        }
    }

    @discardableResult
    public func add(semaphore: TimelineSemaphore, waitValue: UInt64? = nil, throwingContinuation: SemaphoreRunLoop.Source.ThrowingContinuation) throws -> SemaphoreRunLoop.Source {
        try lock.synchronized {
            let source = try SemaphoreRunLoop.Source(with: semaphore, waitValue: waitValue ?? semaphore.value, throwingContinuation: throwingContinuation)
            sources.insert(source)

            try runLoop.add(source: source)

            return source
        }
    }

    public func remove(semaphore: TimelineSemaphore) throws {
        try lock.synchronized {
            let sources = self.sources.filter { $0.semaphore === semaphore }
        
            try runLoop.remove(sources: sources)

            self.sources.subtract(sources)
        }
    }
}

extension SemaphoreWatcher: SemaphoreRunLoopDelegate {
    func removeSignaledSources(_ sources: Set<SemaphoreRunLoop.Source>) {
        lock.synchronized {
            self.sources.subtract(sources)
        }
    }
}
