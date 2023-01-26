//
//  RunLoop.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 03.07.2022.
//

import Foundation
import HijackingHacks

#if os(Linux)
    import LinuxSys
#elseif os(Android) || os(OpenBSD)
#elseif os(Windows)
    import WinSDK
#elseif os(macOS)
    import Darwin
#endif

// TODO: When RunLoopMode is created and placed into runloop - runloops wake up port is placed to this modes port set
// TODO: Track main thread exit via __CFMainThreadHasExited and check all public APIs for main runloop and exiting thread

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

internal let timeoutLimit: TimeInterval = 0

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreFoundation

    public typealias RunLoop1 = Foundation.RunLoop

    public extension RunLoop1 {
        typealias Activity = CoreFoundation.CFRunLoopActivity
    }
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
        public private(set) var isWaiting: Bool = false

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
        public func isFinished(in modeName: RunLoop1.Mode) -> Bool {
            lock.synchronized {
                guard let mode = modes[modeName] else {
                    return true
                }

                return mode.lock.synchronized {
                    mode.isEmpty
                }
            }
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

        fileprivate func notifyObservers(for activity: Activity, mode: RunLoopMode) {
            // runloop and mode are locked on entrance and exit
            let observers = mode.observers.filter { observer in
                // original code does not lock the observer, yet clearly it should because *all* setters to isValid are hidden behind locks implying possible race conditions
                observer.lock.synchronized {
                    observer.activity.contains(activity)
                        && observer.isValid
                        && observer.isFiring == false
                }
            }

            mode.lock.unlock()
            lock.unlock()

            defer {
                lock.lock()
                mode.lock.lock()
            }

            observers.forEach { observer in
                var callBack: Observer.CallBack?
                var shouldInvadliate = false
                observer.lock.synchronized {
                    if observer.isValid && observer.isFiring == false {
                        callBack = observer.callBack
                        shouldInvadliate = observer.repeats
                    }
                }

                if let callBack {
                    observer.isFiring = true
                    callBack(observer, activity)
                    if shouldInvadliate {
                        observer.invalidate()
                    }
                    observer.isFiring = false
                }
            }
        }

        fileprivate func actualRun(in mode: RunLoopMode, name: RunLoop1.Mode, duration: TimeInterval, stopAfterHandle: Bool, previousMode: RunLoopMode?) throws -> RunResult {
            let startTSR: UInt64 = .absoluteTime

            var dispatchMainQueuePort: OSPort? = nil
            let isMainThread = OSNativeThread.isMain

            try lock.synchronized {
                try mode.lock.synchronized {
                    if isMainThread == true, isInMainQueue == false, self === RunLoop1.main, commonModes[name] === mode {
                        dispatchMainQueuePort = OSPort.dispatchMainQueuePort
                    }

                    // var timeoutToken: UInt64 = .zero

                    // switch duration {
                    //     case 0:
                    //         break

                    //     case let duration where duration <= timeoutLimit:
                    //         // // CFRunLoop is using overcommit queues via DISPATCH_QUEUE_OVERCOMMIT. Those are not available publicly and there's a very low chance they are needed. Overcommit for queues means there will always be dedicated thread started for the given queue
                    //         let timeoutQueue: DispatchQueue = isMainThread ? .global(qos: .userInitiated) : .global(qos: .utility)
                    //         let timeoutTimer = DispatchSource.makeTimerSource(flags: [], queue: timeoutQueue)
                    //         let timeoutEventHandler = DispatchWorkItem {
                    //             timeoutToken = 1
                    //         }
                    //         timeoutTimer.setEventHandler(handler: timeoutEventHandler)
                    //         timeoutToken = startTSR + duration.toTSR
                    //         // timeoutTimer.scheduleOneshot(deadline: DispatchTime, leeway: DispatchTimeInterval)
                    //         timeoutTimer.resume()

                    //     default:
                    //         timeoutToken = .max
                    // }
                                    
                    notifyObservers(for: .beforeTimers, mode: mode)
                    notifyObservers(for: .beforeSources, mode: mode)
                    // sources1

                    notifyObservers(for: .beforeWaiting, mode: mode)

                    if let dispatchMainQueuePort {
                        try mode.portSet.addPort(dispatchMainQueuePort)
                    }

                    isWaiting = true
                }
            }

            var context = OSPortSet.Context()
            context.timeout = .seconds(1)

            let wakeUpResult = try mode.portSet.wait(context: context)

            lock.lock()
            mode.lock.lock()
            defer {
                mode.lock.unlock()
                lock.unlock()
            }

            // this is not ideal since if there was an exception throwin from portSet wait this boolean would be in invalid state. ideally this line would be inside defer statement right before waiting on portSet, covered by locks from runloop and runloop mode. but original code did this and we are just achieving parity as much as we can. plus, caller from outside should fatalError on any exception
            isWaiting = false

            if let dispatchMainQueuePort {
                try mode.portSet.removePort(dispatchMainQueuePort)
            }

            notifyObservers(for: .afterWaiting, mode: mode)
            let result: RunResult

            switch wakeUpResult {
                case .awokenPort(let value) where value.isEqual(to: wakeUpPort):
                    try wakeUpPort.acknowledge()
                    result = .handledSource

                case .awokenPort(let value) where value.isEqual(to: mode.timerPort):
                    try mode.timerPort.acknowledge()
                    result = .handledSource

                case .awokenPort(let value) where value.isEqual(to: dispatchMainQueuePort):
                    isInMainQueue = true
                    defer { isInMainQueue = false }
                    let dummy: UnsafeMutableRawPointer? = nil
                    _dispatch_main_queue_callback_4CF(dummy)
                    try dispatchMainQueuePort?.acknowledge()
                    result = .handledSource

                case .timeout:
                    result = .timedOut

                #if os(Windows)
                    case .windowsEvent:
                        break

                    case .inputOutputCompletion:
                        break
                #endif

                case let value:
                    fatalError("Unhandled port set wait result: \(value)")
            }

            return result
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
