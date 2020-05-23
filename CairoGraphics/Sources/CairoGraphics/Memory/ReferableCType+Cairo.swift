//
//  RetainableCType+Cairo.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 12.02.2020.
//

import Foundation
import CCairo
import TinyFoundation

extension cairo_t: RetainableCType {
    public static var retainFunc: (UnsafeMutablePointer<cairo_t>?) -> (UnsafeMutablePointer<cairo_t>?) {
        return cairo_reference
    }
    
    public static var releaseFunc: (UnsafeMutablePointer<cairo_t>?) -> () {
        return cairo_destroy
    }
}

extension cairo_surface_t: RetainableCType {
    public static var retainFunc: (UnsafeMutablePointer<cairo_surface_t>?) -> (UnsafeMutablePointer<cairo_surface_t>?) {
        return cairo_surface_reference
    }
    
    public static var releaseFunc: (UnsafeMutablePointer<cairo_surface_t>?) -> () {
        return cairo_surface_destroy
    }
}

extension cairo_pattern_t: RetainableCType {
    public static var retainFunc: (UnsafeMutablePointer<cairo_pattern_t>?) -> (UnsafeMutablePointer<cairo_pattern_t>?) {
        return cairo_pattern_reference
    }
    
    public static var releaseFunc: (UnsafeMutablePointer<cairo_pattern_t>?) -> () {
        return cairo_pattern_destroy
    }
}
