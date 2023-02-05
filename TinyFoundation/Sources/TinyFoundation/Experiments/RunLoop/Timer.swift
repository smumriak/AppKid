//
//  Timer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.01.2023
//

import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    public typealias Timer1 = Foundation.Timer
#else

    public final class Timer1: Hashable {
        public typealias CallBack = (_ timer: Timer1) -> ()
            
        public let repeats: Bool

        @inlinable @inline(__always)
        @TFValid
        public internal(set) var isValid: Bool = true

        internal let callBack: CallBack
    
        public let timeInterval: TimeInterval
        public var tolerance: TimeInterval = 0.0

        public internal(set) var fireDate: Date

        internal let lock = RecursiveLock()
        internal unowned var runLoop: RunLoop1? = nil
        internal var modes: Set<RunLoopMode> = []

        deinit {
            invalidate()
        }

        public init(fire fireDate: Date, interval timeInterval: TimeInterval, repeats: Bool, block: @escaping CallBack) {
            self.timeInterval = timeInterval
            self.repeats = repeats
            self.callBack = block
            self.fireDate = fireDate
        }

        public convenience init(interval timeInterval: TimeInterval, repeats: Bool, block: @escaping CallBack) {
            self.init(fire: Date(), interval: timeInterval, repeats: repeats, block: block)
        }
        
        public class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping CallBack) -> Timer1 {
            let timer = Timer1(fire: Date(timeIntervalSinceNow: interval), interval: interval, repeats: repeats, block: block)
            RunLoop1.current.addTimer(timer, forMode: .default)
            return timer
        }
    
        public func fire() {
        }

        public func invalidate() {
            guard isValid else { return }

            lock.synchronized {
                runLoop?.removeTimer(self)
            }

            isValid = false
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }

        public static func == (lhs: Timer1, rhs: Timer1) -> Bool {
            return lhs === rhs
        }
    }

    public extension RunLoop1 {
        @_transparent
        internal func removeTimer(_ timer: Timer1) {
            lock.synchronized {
                commonModeItems.timers.remove(timer)
                modes.values.forEach { mode in
                    mode.removeTimer(timer)
                }
                timer.lock.synchronized {
                    timer.runLoop = nil
                }
            }
        }

        func addTimer(_ timer: Timer1, forMode modeName: Mode) {
            lock.synchronized {
                if modeName == .common {
                    commonModeItems.timers.insert(timer)
                    commonModes.forEach {
                        modes[$0]?.addTimer(timer)
                    }
                } else {
                    modes[modeName]?.addTimer(timer)
                }
                timer.lock.synchronized {
                    timer.runLoop = self
                }
            }
        }
    }
#endif
