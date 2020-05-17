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

public final class ReferablePointer<Pointee> where Pointee: ReferableCType {
    public typealias ReferablePointer_t = UnsafeMutablePointer<Pointee>
    public var pointer: ReferablePointer_t {
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

    public init(with pointer: ReferablePointer_t) {
        self.pointer = pointer.retain()
    }
    
    public init(other: ReferablePointer<Pointee>) {
        self.pointer = other.pointer.retain()
    }
}
