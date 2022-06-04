//
//  PangoEllipsizeMode.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.06.2022.
//

import CPango

public typealias PangoEllipsizeMode = CPango.PangoEllipsizeMode

public extension PangoEllipsizeMode {
    static let none: PangoEllipsizeMode = PANGO_ELLIPSIZE_NONE
    static let start: PangoEllipsizeMode = PANGO_ELLIPSIZE_START
    static let middle: PangoEllipsizeMode = PANGO_ELLIPSIZE_MIDDLE
    static let end: PangoEllipsizeMode = PANGO_ELLIPSIZE_END
}
