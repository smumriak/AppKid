//
//  RetainablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

public protocol RetainableCType: ReleasableCType {
    static var retainFunc: (_ pointer: SmartPointer<Self>.Pointer_t?) -> (SmartPointer<Self>.Pointer_t?) { get }
}

public extension UnsafeMutablePointer where Pointee: RetainableCType {
    @discardableResult
    func retain() -> UnsafeMutablePointer<Pointee> {
        defer { globalRetainCount.increment() }

        return Pointee.retainFunc(self)!
    }
}

public class RetainablePointer<Pointee>: ReleasablePointer<Pointee> where Pointee: RetainableCType {
    public override var pointer: UnsafeMutablePointer<Pointee> {
        willSet {
            newValue.retain()
        }
        didSet {
            oldValue.release()
        }
    }

    public override init(with pointer: Pointer_t) {
        super.init(with: pointer.retain())
    }

    public init(withRetained pointer: Pointer_t) {
        defer { globalRetainCount.increment() }
        
        super.init(with: pointer)
    }

    public convenience init(other: RetainablePointer<Pointee>) {
        self.init(with: other.pointer)
    }
}
