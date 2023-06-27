//
//  RunLoopMode.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 14.01.2023
//

// #if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
@_spi(AppKid)
public final class RunLoopMode: Hashable {
    public let name: RunLoop1.Mode
    internal let lock = RecursiveLock()
    internal var portSet: OSPortSet
    internal var timerPort: OSTimerPort
    public internal(set) var activity: RunLoop1.Activity = []
    internal var sources: Set<RunLoop1.Source> = []
    internal var observers: [RunLoop1.Observer] = []
    internal var timers: [Timer1] = []

    deinit {
        do {
            try portSet.free()
            try timerPort.free()
        } catch {
            debugPrint("Freeing ports failed in RunLoopMode deainit with error: \(error)")
        }
    }
    
    public init(name: RunLoop1.Mode) {
        self.name = name
        do {
            try portSet = OSPortSet()
            try timerPort = OSTimerPort()
            try portSet.addPort(timerPort)
        } catch {
            fatalError("Sorry, RunLoop experienced an error while trying to allocate native OS port set: \(error.localizedDescription)")
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: RunLoopMode, rhs: RunLoopMode) -> Bool {
        return lhs === rhs
    }
}

internal extension RunLoopMode {
    @_transparent
    func addSource(_ source: RunLoop1.Source) {
        lock.synchronized {
            source.context.addTo(portSet: &portSet)
            sources.insert(source)
        }
    }

    @_transparent
    func removeSource(_ source: RunLoop1.Source) {
        lock.synchronized {
            source.context.removeFrom(portSet: &portSet)
            sources.remove(source)
        }
    }

    @_transparent
    func addObserver(_ observer: RunLoop1.Observer) {
        lock.synchronized {
            // TODO: maybe check for duplicates
            observers.append(observer)
            // smumriak: original code never removes it from the known activites. assuming the expecation is "observer should never be removed from runloop"
            activity.formUnion(observer.activity)
        }
    }

    @_transparent
    func removeObserver(_ observer: RunLoop1.Observer) {
        lock.synchronized {
            if let index = observers.firstIndex(of: observer) {
                observers.remove(at: index)
            }
        }
    }

    @_transparent
    func addTimer(_ timer: Timer1, runLoop: RunLoop1) {
        lock.synchronized {
            timer.lock.synchronized {
                if timer.modes.contains(name) { return }

                if timer.runLoop == nil {
                    timer.runLoop = runLoop
                } else if timer.runLoop != runLoop {
                    return
                }
                
                // TODO: Reposition timer in timers list
            }
        }
    }

    @_transparent
    func removeTimer(_ timer: Timer1) {
        lock.synchronized {
            if let index = timers.firstIndex(of: timer) {
                timers.remove(at: index)
                timer.modes.remove(self.name)
                if timer.modes.isEmpty {
                    timer.runLoop = nil
                }

                // TODO: Arm next timer
            }
        }
    }

    @_transparent
    func repositionTimer(_ timer: Timer1, isAlreadyPresent: Bool) {
        // smumriak: mode is locked on enter and exit
        if isAlreadyPresent {
            if let index = timers.firstIndex(of: timer) {
                timers.remove(at: index)
            } else {
                return
            }
        }

        let newIndex = timers.findInsertionIndex(for: timer, keyPath: \.fireDate, options: .anyEqual)
        timers.insert(timer, at: newIndex)
        // TODO: Arm next timer
    }
}

#if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    public extension RunLoop1 {
        struct Mode: RawRepresentable, Equatable, Hashable {
            public typealias RawValue = String
            public let rawValue: RawValue

            public init(rawValue: RawValue) {
                self.rawValue = rawValue
            }

            public init(_ rawValue: RawValue) {
                self.rawValue = rawValue
            }

            public static let `default` = RunLoop1.Mode("RunLoop.Mode.Default")
            public static let common = RunLoop1.Mode("RunLoop.Mode.Common")
        }
    }
#endif
