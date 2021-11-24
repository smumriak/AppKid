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
    public static let retainFunc = cairo_reference
    public static let releaseFunc = cairo_destroy
}

extension cairo_surface_t: RetainableCType {
    public static let retainFunc = cairo_surface_reference
    public static var releaseFunc = cairo_surface_destroy
}

extension cairo_pattern_t: RetainableCType {
    public static let retainFunc = cairo_pattern_reference    
    public static let releaseFunc = cairo_pattern_destroy
}
