//
//  cairo_line_join_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.06.2021.
//

import CCairo

public typealias cairo_line_join_t = CCairo.cairo_line_join_t

public extension cairo_line_join_t {
    static let miter: cairo_line_join_t = CAIRO_LINE_JOIN_MITER
    static let round: cairo_line_join_t = CAIRO_LINE_JOIN_ROUND
    static let bevel: cairo_line_join_t = CAIRO_LINE_JOIN_BEVEL
}
