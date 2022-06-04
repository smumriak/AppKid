//
//  cairo_hint_style_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.06.2022.
//

import CCairo

public typealias cairo_hint_style_t = CCairo.cairo_hint_style_t

public extension cairo_hint_style_t {
    static let `default`: cairo_hint_style_t = CAIRO_HINT_STYLE_DEFAULT
    static let none: cairo_hint_style_t = CAIRO_HINT_STYLE_NONE
    static let slight: cairo_hint_style_t = CAIRO_HINT_STYLE_SLIGHT
    static let medium: cairo_hint_style_t = CAIRO_HINT_STYLE_MEDIUM
    static let full: cairo_hint_style_t = CAIRO_HINT_STYLE_FULL
}
