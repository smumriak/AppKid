//
//  SwiftGMainContext.swift
//  SwiftyGLib
//
//  Created by Serhii Mumriak on 20.11.2021.
//

import Foundation
import CGlib
import TinyFoundation
// Thread.current.threadDictionary
public class SwiftGMainContext: HandleStorage<SmartPointer<_GMainContext>> {
    internal func acquireOwnership() {
        if g_main_context_acquire(handle) == 0 {
            fatalError("SwiftGMainContext failed to acquire ownership over underlying GMainContext. This means something nasty is going own and the given context is owned by another thread")
        }
    }

    internal func releaseOwnership() {
        g_main_context_release(handle)
    }

    internal func withAcquiredOwnership<T>(_ body: () throws -> (T)) rethrows -> T {
        acquireOwnership()
        defer {
            releaseOwnership()
        }

        return try body()
    }

    func prepare() -> Bool {
        return withAcquiredOwnership {
            return g_main_context_prepare(handle, nil) != 0
        }
    }

    internal private(set) var fileDescriptorsToObserve: [GPollFD] = []

    internal func updateFileDescriptorsToObserve() -> [GPollFD] {
        return withAcquiredOwnership {
            var timeout: gint = 0
            let count = g_main_context_query(handle, .max, nil, nil, 0)

            if count > 0 {
                fileDescriptorsToObserve = Array(repeating: GPollFD(), count: Int(count))

                fileDescriptorsToObserve.withUnsafeMutableBufferPointer {
                    _ = g_main_context_query(handle, .max, &timeout, $0.baseAddress!, gint($0.count))
                }
            } else {
                fileDescriptorsToObserve = []
            }

            return fileDescriptorsToObserve
        }
    }

    internal var needsToDispatchEvents: Bool {
        if fileDescriptorsToObserve.isEmpty {
            return false
        }

        return withAcquiredOwnership {
            return fileDescriptorsToObserve.withUnsafeMutableBufferPointer {
                let result = g_main_context_check(handle, .max, $0.baseAddress, gint($0.count))
                return result == 1
            }
        }
    }

    public func dispatchEvents() {
        withAcquiredOwnership {
            g_main_context_dispatch(handle)
        }
    }

    public func wakeup() {
        withAcquiredOwnership {
            g_main_context_wakeup(handle)
        }
    }

    public func oneShot() {
        withAcquiredOwnership {
            _ = g_main_context_iteration(handle, 1)
        }
    }
}
