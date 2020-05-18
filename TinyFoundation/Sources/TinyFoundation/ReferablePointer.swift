//
//  ReferablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

public protocol ReferableCType {
    var retainFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
    var releaseFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> () { get }
}

public extension UnsafeMutablePointer where Pointee: ReferableCType {
    @discardableResult
    func retain() -> UnsafeMutablePointer<Pointee> {
        return pointee.retainFunc(self)!
    }

    func release() {
        pointee.releaseFunc(self)
    }
}

public final class ReferablePointer<Pointee>: SmartPointer where Pointee: ReferableCType {
    public typealias Pointer_t = UnsafeMutablePointer<Pointee>
    public var pointer: Pointer_t {
        willSet {
            pointer.release()
        }
        didSet {
            pointer.retain()
        }
    }
    
    deinit {
        pointer.release()
    }

    public required init(with pointer: Pointer_t) {
        self.pointer = pointer.retain()
    }
    
    public init(other: ReferablePointer<Pointee>) {
        self.pointer = other.pointer.retain()
    }
}
