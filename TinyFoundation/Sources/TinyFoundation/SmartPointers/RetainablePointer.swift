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
        return Pointee.retainFunc(self)!
    }
}

public class RetainablePointer<Pointee>: ReleasablePointer<Pointee> where Pointee: RetainableCType {
    public override var pointer: UnsafeMutablePointer<Pointee> {
        willSet {
            pointer.release()
        }
        didSet {
            pointer.retain()
        }
    }

    public override init(with pointer: Pointer_t) {
        super.init(with: pointer.retain())
    }

    public convenience init(other: RetainablePointer<Pointee>) {
        self.init(with: other.pointer)
    }
}