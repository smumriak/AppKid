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
    class Source {
        internal let lock = RecursiveLock()
        public let order: Int
        internal var signaledTime = ManagedAtomic<UInt64>(0)
        internal let context: any RunLoopSourceContext

        public init(order: Int, context: any RunLoopSourceContext) {
            self.order = order
            self.context = context
        }

        public func signal() {
        }

        public var isSignaled: Bool {
            return false
        }
    }
}
