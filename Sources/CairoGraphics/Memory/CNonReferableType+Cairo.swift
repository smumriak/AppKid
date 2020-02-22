//
//  CNonReferableType+Cairo.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19/2/20.
//

import Foundation
import CCairo

extension cairo_font_options_t: CNonReferableType {
    public var copyFunc: (UnsafePointer<cairo_font_options_t>?) -> (UnsafeMutablePointer<cairo_font_options_t>?) {
        return cairo_font_options_copy
    }

    public var destroyFunc: (UnsafeMutablePointer<cairo_font_options_t>?) -> () {
        return cairo_font_options_destroy
    }
}
