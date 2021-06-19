//
//  cairo_line_cap_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.06.2021.
//

import CCairo

public typealias cairo_line_cap_t = CCairo.cairo_line_cap_t

public extension cairo_line_cap_t {
    static let butt: cairo_line_cap_t = CAIRO_LINE_CAP_BUTT
    static let round: cairo_line_cap_t = CAIRO_LINE_CAP_ROUND
    static let square: cairo_line_cap_t = CAIRO_LINE_CAP_SQUARE
}
