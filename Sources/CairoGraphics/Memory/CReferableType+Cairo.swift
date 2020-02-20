//
//  CReferableType+Cairo.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 12/2/20.
//

import Foundation
import CCairo

extension cairo_t: CReferableType {
    public var retainFunc: (UnsafeMutablePointer<cairo_t>?) -> (UnsafeMutablePointer<cairo_t>?) {
        return cairo_reference
    }
    
    public var releaseFunc: (UnsafeMutablePointer<cairo_t>?) -> () {
        return cairo_destroy
    }
}

extension cairo_surface_t: CReferableType {
    public var retainFunc: (UnsafeMutablePointer<cairo_surface_t>?) -> (UnsafeMutablePointer<cairo_surface_t>?) {
        return cairo_surface_reference
    }
    
    public var releaseFunc: (UnsafeMutablePointer<cairo_surface_t>?) -> () {
        return cairo_surface_destroy
    }
}

extension cairo_pattern_t: CReferableType {
    public var retainFunc: (UnsafeMutablePointer<cairo_pattern_t>?) -> (UnsafeMutablePointer<cairo_pattern_t>?) {
        return cairo_pattern_reference
    }
    
    public var releaseFunc: (UnsafeMutablePointer<cairo_pattern_t>?) -> () {
        return cairo_pattern_destroy
    }
}
