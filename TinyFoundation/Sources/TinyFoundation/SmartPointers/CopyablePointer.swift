//
//  CopyablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

public protocol CopyableCType: ReleasableCType {
    static var copyFunc: (_ pointer: UnsafePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
}

public extension UnsafeMutablePointer where Pointee: CopyableCType {
    func copy() -> UnsafeMutablePointer<Pointee> {
        return Pointee.copyFunc(self)!
    }
}

public final class CopyablePointer<Pointee>: ReleasablePointer<Pointee> where Pointee: CopyableCType {
    public override var pointer: UnsafeMutablePointer<Pointee> {
        get {
            return super.pointer
        }
        set {
            super.pointer = newValue.copy()
        }
    }

    public override init(with pointer: Pointer_t) {
        super.init(with: pointer)
    }

    public init(copy other: CopyablePointer<Pointee>) {
        super.init(with: other.pointer.copy())
    }
}
