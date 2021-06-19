//
//  cairo_fill_rule_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.06.2021.
//

import CCairo

public typealias cairo_fill_rule_t = CCairo.cairo_fill_rule_t

public extension cairo_fill_rule_t {
    static let winding: cairo_fill_rule_t = CAIRO_FILL_RULE_WINDING
    static let evenOdd: cairo_fill_rule_t = CAIRO_FILL_RULE_EVEN_ODD
}
