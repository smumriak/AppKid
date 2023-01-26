//
//  RunLoopObserver.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.01.2023
//

public extension RunLoop1 {
    final class Observer {
        public typealias CallBack = (_ observer: Observer, _ activity: RunLoop1.Activity) -> ()
        public internal(set) var activity: RunLoop1.Activity
        public internal(set) var repeats: Bool
        public internal(set) var oder: Int
        public internal(set) var isValid: Bool = true
        public internal(set) var callBack: CallBack

        internal let lock = RecursiveLock()
        internal var isFiring: Bool = false
        internal unowned var runLoop: RunLoop1? = nil
        
        public func invalidate() {
            guard let runLoop else { return }
        }

        public init(activity: RunLoop1.Activity, repeats: Bool, oder: Int, callBack: @escaping CallBack) {
            self.activity = activity
            self.repeats = repeats
            self.oder = oder
            self.callBack = callBack
        }
    }
}
