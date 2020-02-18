//
//  CReferablePointerStorage.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 13/2/20.
//

import Foundation
import CCairo

public protocol CReferableType {
    var retainFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
    var releaseFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> () { get }
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
