//
//  RunLoopSource.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 14.01.2023
//
import Atomics

public protocol RunLoopSourceContext: AnyObject, Hashable, Equatable {
    associatedtype Port: OSPortProtocol
    var port: Port { get }
    func perform()
}

public extension RunLoop1 {
    final class Source {
        internal let lock = RecursiveLock()
        public let order: Int
        internal var signaledTime = ManagedAtomic<UInt64>(0)
        internal let context: any RunLoopSourceContext
        internal var runLoops: [RunLoop1] = []
        internal var isValid: Bool = true
        public internal(set) var isSignaled: Bool = false
        
        public init(order: Int, context: any RunLoopSourceContext) {
            self.order = order
            self.context = context
        }

        public func signal() {
        }

        public func invalidate() {
            guard isValid else { return }
            
            lock.synchronized {
                isValid = false
                isSignaled = false

                if runLoops.isEmpty == false {
                    let runLoopsCopy = runLoops
                    lock.desynchronized {
                        // runLoopsCopy.forEach {
                        // $0.removeSource
                        // }
                    }
                }
            }
        }
    }
}
