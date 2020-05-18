//
//  CopyablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

public protocol CopyableCType: DestructableCType {
    var copyFunc: (_ pointer: UnsafePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
}

public extension UnsafeMutablePointer where Pointee: CopyableCType {
    func copy() -> UnsafeMutablePointer<Pointee> {
        return pointee.copyFunc(self)!
    }
}

public final class CopyablePointer<Pointee>: DestructablePointer<Pointee> where Pointee: CopyableCType{
    public typealias Pointer_t = UnsafeMutablePointer<Pointee>

    public required init(with pointer: Pointer_t) {
        super.init(with: pointer)
    }

    public init(copy other: CopyablePointer<Pointee>) {
        super.init(with: other.pointer.copy())
    }
}
