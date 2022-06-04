//
//  cairo_antialias_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.06.2022.
//

import CCairo

public typealias cairo_antialias_t = CCairo.cairo_antialias_t

public extension cairo_antialias_t {
    static let `default`: cairo_antialias_t = CAIRO_ANTIALIAS_DEFAULT
    static let none: cairo_antialias_t = CAIRO_ANTIALIAS_NONE
    static let gray: cairo_antialias_t = CAIRO_ANTIALIAS_GRAY
    static let subpixel: cairo_antialias_t = CAIRO_ANTIALIAS_SUBPIXEL
    static let fast: cairo_antialias_t = CAIRO_ANTIALIAS_FAST
    static let good: cairo_antialias_t = CAIRO_ANTIALIAS_GOOD
    static let best: cairo_antialias_t = CAIRO_ANTIALIAS_BEST
}
