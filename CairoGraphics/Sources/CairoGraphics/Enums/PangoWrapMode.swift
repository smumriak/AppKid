//
//  PangoWrapMode.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.06.2022.
//

import CPango

public typealias PangoWrapMode = CPango.PangoWrapMode

public extension PangoWrapMode {
    static let word: PangoWrapMode = PANGO_WRAP_WORD
    static let char: PangoWrapMode = PANGO_WRAP_CHAR
    static let wordChar: PangoWrapMode = PANGO_WRAP_WORD_CHAR
}
