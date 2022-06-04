//
//  cairo_subpixel_order_t.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.06.2022.
//

import CCairo

public typealias cairo_subpixel_order_t = CCairo.cairo_subpixel_order_t

public extension cairo_subpixel_order_t {
    static let `default`: cairo_subpixel_order_t = CAIRO_SUBPIXEL_ORDER_DEFAULT
    static let rgb: cairo_subpixel_order_t = CAIRO_SUBPIXEL_ORDER_RGB
    static let bgr: cairo_subpixel_order_t = CAIRO_SUBPIXEL_ORDER_BGR
    static let vrgb: cairo_subpixel_order_t = CAIRO_SUBPIXEL_ORDER_VRGB
    static let vbgr: cairo_subpixel_order_t = CAIRO_SUBPIXEL_ORDER_VBGR
}
