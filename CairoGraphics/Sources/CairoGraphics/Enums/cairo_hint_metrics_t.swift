//
//  cairo_hint_metrics_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.06.2022.
//

import CCairo

public typealias cairo_hint_metrics_t = CCairo.cairo_hint_metrics_t

public extension cairo_hint_metrics_t {
    static let `default`: cairo_hint_metrics_t = CAIRO_HINT_METRICS_DEFAULT
    static let off: cairo_hint_metrics_t = CAIRO_HINT_METRICS_OFF
    static let on: cairo_hint_metrics_t = CAIRO_HINT_METRICS_ON
}
