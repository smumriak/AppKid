//
//  RunLoop.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 03.07.2022.
//

import Foundation
import HijackingHacks

#if os(Linux)
    import CLinuxSys
#elseif os(Android) || os(OpenBSD)
#elseif os(Windows)
//    import whatever
#elseif os(macOS)
    import Darwin
#endif

// TODO: When RunLoopMode is created and placed into runloop - runloops wake up port is placed to this modes port set

internal let tsrRate: TimeInterval = {
    #if os(Linux)
        var timespec = timespec()
        let result = clock_getres(CLOCK_MONOTONIC /* clock_id */,
                                  &timespec /* res */ )
        if result != 0 {
            fatalError("Sorry, getting clock resulution failed with error: \(POSIXErrorCode(rawValue: errno)!)")
        }
        return TimeInterval(timespec.tv_sec) + (1000000000 * TimeInterval(timespec.tv_nsec))
    #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        return 1
    #elseif os(Android)
        return 1
    #elseif os(Windows)
        // QueryUnbiasedInterruptTimePrecise returns system time in units of 100 nanoseconds. Divide it by 10^7 to get seconds
        return 10000000
    #else
        return 1
    #endif
}()

internal let oneOverTSRRate: TimeInterval = 1.0 / tsrRate

internal extension TimeInterval {
    @_transparent
    var toTSR: UInt64 {
        let result = Int64(self * tsrRate)
        if result > Int64.max / 2 {
            return UInt64(Int64.max / 2)
        } else {
            return UInt64(result)
        }
    }
}

internal extension UInt64 {
    @_transparent
    static var absoluteTime: UInt64 {
        #if os(Linux)
            var timespec = timespec()
            let result = clock_gettime(CLOCK_MONOTONIC /* clock_id */,
                                       &timespec /* res */ )
            assert(result != 0, "Sorry, failed to get current time from OS")
            return UInt64(timespec.tv_nsec) + UInt64(timespec.tv_sec * 1000000000)

        #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            return 0
        #elseif os(Android)
            return 0
        #elseif os(Windows)
            return 0
        #else
            return 0
        #endif
    }

    @_transparent
    var fromTSR: TimeInterval {
        TimeInterval(self) * oneOverTSRRate
    }

    @_transparent
    var timeIntervalUntilTSR: TimeInterval {
        let now = UInt64.absoluteTime
        if self >= now {
            return TimeInterval(self - now)
        } else {
            return -TimeInterval(now - self)
        }
    }

    @_transparent
    var tsrToNanoseconds: UInt64 {
        UInt64((TimeInterval(self) * tsrRate * 1000000000).rounded(.down))
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    public typealias RunLoop1 = Foundation.RunLoop
#else
    import HijackingHacks

    internal var isInMainQueue = false

    public final class RunLoop1 {
        enum RunResult {
            case finished
            case stopped
            case timedOut
            case handledSource
        }

        @Synchronized @_spi(AppKid)
        public static var runLoops: [ObjectIdentifier: RunLoop1] = [:]

        @_spi(AppKid)
        public unowned var thread: Thread = .current
        @_spi(AppKid)
        public var items: [any RunLoopItem] = []
        @_spi(AppKid)
        public var modes: [RunLoop1.Mode: RunLoopMode] = [:]
        @_spi(AppKid)
        public var commonModes: [RunLoop1.Mode: RunLoopMode] = [:]

        public var currentMode: RunLoop1.Mode? {
            _currentMode?.name
        }

        @_spi(AppKid)
        public fileprivate(set) var _currentMode: RunLoopMode? = nil

        public struct Activity: OptionSet {
            public typealias RawValue = UInt64
            public let rawValue: RawValue

            public init(rawValue: RawValue) {
                self.rawValue = rawValue
            }

            public static let entry = Activity(rawValue: 1 << 0)
            public static let beforeTimers = Activity(rawValue: 1 << 1)
            public static let beforeSources = Activity(rawValue: 1 << 2)
            public static let beforeWaiting = Activity(rawValue: 1 << 5)
            public static let afterWaiting = Activity(rawValue: 1 << 6)
            public static let exit = Activity(rawValue: 1 << 7)
            public static let all = Activity(rawValue: 0x0FFFFFFF)
        }

        internal let lock = RecursiveLock()
        internal let wakeUpPort: OSPort
        public let notifyPort: OSPort

        deinit {
            try? wakeUpPort.free()
            try? notifyPort.free()
        }

        @_spi(AppKid)
        public init(thread: Thread) {
            self.thread = thread
            do {
                try wakeUpPort = OSPort()
                try notifyPort = OSPort()
            } catch {
                fatalError("Sorry, RunLoop experienced an error while trying to allocate native OS port: \(error.localizedDescription)")
            }
        }

        @_spi(AppKid)
        public func isFinished(in mode: RunLoopMode) -> Bool {
            // lock.synchronized {
            //     mode.lock.synchronized {
            false
            // }
            // }
        }

        class var current: RunLoop1 {
            return getRunLoop(.current)
        }

        class var main: RunLoop1 {
            return getRunLoop(.main)
        }

        private static func getRunLoop(_ thread: Thread) -> RunLoop1 {
            let identifier = ObjectIdentifier(thread)
            return $runLoops.synchronized {
                if let result = runLoops[identifier] {
                    return result
                } else {
                    let result = RunLoop1(thread: thread)

                    runLoops[identifier] = result

                    thread.deinitHook = {
                        RunLoop1.runLoops[identifier] = nil
                    }

                    return result
                }
            }
        }

        internal func notifyObservers(for activity: Activity) {
        }

        fileprivate func actualRun(in mode: RunLoopMode, name: RunLoop1.Mode, duration: TimeInterval, stopAfterHandle: Bool, previousMode: RunLoopMode?) throws -> RunResult {
            var dispatchMainQueuePort: OSPort? = nil

            try lock.synchronized {
                try mode.lock.synchronized {
                    if OSNativeThread.isMain, isInMainQueue == false, self === RunLoop1.main, commonModes[name] === mode {
                        dispatchMainQueuePort = OSPort.dispatchMainQueuePort
                    }
        
                    if let dispatchMainQueuePort {
                        try mode.portSet.addPort(dispatchMainQueuePort)
                    }

                    // create timout timer via GCD
            
                    notifyObservers(for: .beforeTimers)
                    notifyObservers(for: .beforeSources)
                    // sources1

                    notifyObservers(for: .beforeWaiting)
                }
            }

            var context = OSPortSet.Context()
            context.timeout = .seconds(1)

            let wakeUpResult = try mode.portSet.waitForWakeUp(context: context)

            lock.lock()
            mode.lock.unlock()
            defer {
                mode.lock.unlock()
                lock.unlock()
            }

            if let dispatchMainQueuePort {
                try mode.portSet.removePort(dispatchMainQueuePort)
            }

            notifyObservers(for: .afterWaiting)
            if case let .awokenPort(value) = wakeUpResult {
                switch value {
                    case let value where value.isEqual(to: wakeUpPort):
                        try wakeUpPort.acknowledgeWakeUp()

                    case let value where value.isEqual(to: mode.timerPort):
                        try mode.timerPort.acknowledgeWakeUp()

                    case let value where value.isEqual(to: dispatchMainQueuePort):
                        isInMainQueue = true
                        defer { isInMainQueue = false }
                        let dummy: UnsafeMutableRawPointer? = nil
                        _dispatch_main_queue_callback_4CF(dummy)
                        try dispatchMainQueuePort?.acknowledgeWakeUp()
                    
                    default:
                        break
                }
            }

            return .handledSource
        }

        @discardableResult
        internal func run(in modeName: RunLoop1.Mode, duration: TimeInterval, returnAfterHandled: Bool) -> RunResult {
            if modeName == .common {
                return .finished
            }
        
            return lock.synchronized {
                guard let mode = modes[modeName] else {
                    return .finished
                }

                return mode.lock.synchronized {
                    if mode.isEmpty {
                        return .finished
                    }

                    if isFinished(in: mode) {
                        return .finished
                    }

                    let previousMode = _currentMode
                    _currentMode = mode

                    let result: RunResult
                
                    do {
                        try result = actualRun(in: mode, name: modeName, duration: duration, stopAfterHandle: returnAfterHandled, previousMode: previousMode)
                    } catch {
                        fatalError("Sorry, RunLoop cought an error while running: \(error.localizedDescription)")
                    }

                    _currentMode = previousMode

                    return result
                }
            }
        }

        public func run(mode modeName: RunLoop1.Mode, before limitDate: Date) -> Bool {
            let duration = limitDate.timeIntervalSince(Date())
            run(in: modeName, duration: duration, returnAfterHandled: true)
            return false
        }
    }

    private let kDeinitHook: AnyHashable = kDeinitHook

    @_spi(AppKid)
    public extension Thread {
        class DeinitHook {
            public typealias Callback = () -> ()

            let callback: Callback

            deinit {
                callback()
            }

            public init(_ callback: @escaping Callback) {
                self.callback = callback
            }
        }

        var deinitHook: DeinitHook.Callback? {
            get {
                return (threadDictionary[kDeinitHook] as? DeinitHook)?.callback
            }
            set {
                if let newValue = newValue {
                    threadDictionary[kDeinitHook] = DeinitHook(newValue)
                }
            }
        }
    }
#endif
