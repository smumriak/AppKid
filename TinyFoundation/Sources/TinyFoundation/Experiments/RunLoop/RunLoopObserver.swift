//
//  RunLoopObserver.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.01.2023
//

public extension RunLoop1 {
    final class Observer: Hashable {
        public typealias CallBack = (_ observer: Observer, _ activity: RunLoop1.Activity) -> ()
        public internal(set) var activity: RunLoop1.Activity
        public internal(set) var repeats: Bool
        public internal(set) var oder: Int
        
        @inlinable @inline(__always)
        @TFValid
        public internal(set) var isValid: Bool = true
        
        public internal(set) var callBack: CallBack

        internal let lock = RecursiveLock()
        internal var isFiring: Bool = false
        internal unowned var runLoop: RunLoop1? = nil

        deinit {
            invalidate()
        }
        
        public init(activity: RunLoop1.Activity, repeats: Bool, oder: Int, callBack: @escaping CallBack) {
            self.activity = activity
            self.repeats = repeats
            self.oder = oder
            self.callBack = callBack
        }

        public func invalidate() {
            guard isValid else { return }
            
            lock.synchronized {
                runLoop?.removeObserver(self)
            }

            isValid = false
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }

        public static func == (lhs: Observer, rhs: Observer) -> Bool {
            return lhs === rhs
        }
    }

    @_transparent
    internal func removeObserver(_ observer: Observer) {
        lock.synchronized {
            commonModeItems.observers.remove(observer)
            modes.values.forEach { mode in
                mode.removeObserver(observer)
            }
            observer.lock.synchronized {
                observer.runLoop = nil
            }
        }
    }

    func addObserver(_ observer: Observer, mode modeName: Mode) {
        observer.lock.synchronized {
            guard observer.runLoop == nil else { return }
            
            lock.synchronized {
                if commonModeItems.observers.contains(observer) == false {
                    commonModeItems.observers.insert(observer)
                }
                if modeName == .common {
                    commonModes.forEach {
                        modes[$0]?.addObserver(observer)
                    }
                } else {
                    modes[modeName]?.addObserver(observer)
                }
            }

            observer.runLoop = nil
        }
    }

    func removeObserver(_ observer: Observer, mode modeName: Mode) {
        observer.lock.synchronized {
            guard observer.runLoop == self else { return }

            lock.synchronized {
                if modeName == .common {
                    commonModeItems.observers.remove(observer)
                    commonModes.forEach {
                        modes[$0]?.removeObserver(observer)
                    }
                } else {
                    modes[modeName]?.removeObserver(observer)
                }

                observer.runLoop = nil
            }
        }
    }
}
