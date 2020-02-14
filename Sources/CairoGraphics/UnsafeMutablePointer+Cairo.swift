//
//  UnsafeMutablePointer+Cairo.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 12/2/20.
//

import Foundation
import CCairo

public protocol CairoReferableType {
    var retainFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
    var releaseFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> () { get }
}

public extension UnsafeMutablePointer where Pointee: CairoReferableType {
    @discardableResult
    func retain() -> UnsafeMutablePointer<Pointee> {
        return pointee.retainFunc(self)!
    }
    
    func release() {
        pointee.releaseFunc(self)
    }
}

extension cairo_t: CairoReferableType {
    public var retainFunc: (UnsafeMutablePointer<cairo_t>?) -> (UnsafeMutablePointer<cairo_t>?) {
        return cairo_reference
    }
    
    public var releaseFunc: (UnsafeMutablePointer<cairo_t>?) -> () {
        return cairo_destroy
    }
}

extension cairo_surface_t: CairoReferableType {
    public var retainFunc: (UnsafeMutablePointer<cairo_surface_t>?) -> (UnsafeMutablePointer<cairo_surface_t>?) {
        return cairo_surface_reference
    }
    
    public var releaseFunc: (UnsafeMutablePointer<cairo_surface_t>?) -> () {
        return cairo_surface_destroy
    }

}

extension cairo_pattern_t: CairoReferableType {
    public var retainFunc: (UnsafeMutablePointer<cairo_pattern_t>?) -> (UnsafeMutablePointer<cairo_pattern_t>?) {
        return cairo_pattern_reference
    }
    
    public var releaseFunc: (UnsafeMutablePointer<cairo_pattern_t>?) -> () {
        return cairo_pattern_destroy
    }

}
