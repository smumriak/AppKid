//
//  CReferablePointerStorage.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation
import CCairo

public protocol CReferableType {
    var retainFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
    var releaseFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> () { get }
}

public protocol CNonReferableType {
    var copyFunc: (_ pointer: UnsafePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
    var destroyFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> () { get }
}

public extension UnsafeMutablePointer where Pointee: CReferableType {
    @discardableResult
    func retain() -> UnsafeMutablePointer<Pointee> {
        return pointee.retainFunc(self)!
    }

    func release() {
        pointee.releaseFunc(self)
    }
}

public extension UnsafeMutablePointer where Pointee: CNonReferableType {
    func copy() -> UnsafeMutablePointer<Pointee> {
        return pointee.copyFunc(self)!
    }

    func destroy() {
        pointee.destroyFunc(self)
    }
}

public final class CReferablePointer<Pointee> where Pointee: CReferableType {
    public typealias CReferablePointer_t = UnsafeMutablePointer<Pointee>
    public var pointer: CReferablePointer_t {
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

    public init(with pointer: CReferablePointer_t) {
        self.pointer = pointer.retain()
    }
    
    public init(other: CReferablePointer<Pointee>) {
        self.pointer = other.pointer.retain()
    }
}

public final class CNonReferablePointer<Pointee> where Pointee: CNonReferableType {
    public typealias CNonReferablePointer_t = UnsafeMutablePointer<Pointee>
    public var pointer: CNonReferablePointer_t

    deinit {
        pointer.destroy()
    }

    public init(with pointer: CNonReferablePointer_t) {
        self.pointer = pointer
    }

    public init(copy other: CNonReferablePointer<Pointee>) {
        self.pointer = other.pointer.copy()
    }
}
