//
//  PangoAlignment.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.06.2022.
//

import CPango

public typealias PangoAlignment = CPango.PangoAlignment

public extension PangoAlignment {
    static let left: PangoAlignment = PANGO_ALIGN_LEFT
    static let center: PangoAlignment = PANGO_ALIGN_CENTER
    static let right: PangoAlignment = PANGO_ALIGN_RIGHT
}
