//
//  cairo_format_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.06.2021.
//

import CCairo

public typealias cairo_format_t = CCairo.cairo_format_t

public extension cairo_format_t {
    static let invalid: cairo_format_t = CAIRO_FORMAT_INVALID
    static let argb32: cairo_format_t = CAIRO_FORMAT_ARGB32
    static let rgb24: cairo_format_t = CAIRO_FORMAT_RGB24
    static let a8: cairo_format_t = CAIRO_FORMAT_A8
    static let a1: cairo_format_t = CAIRO_FORMAT_A1
    static let rgb16_565: cairo_format_t = CAIRO_FORMAT_RGB16_565
    static let rgb30: cairo_format_t = CAIRO_FORMAT_RGB30
}
