//
//  CNonReferableType+Pango.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.02.2020.
//

import Foundation
import CPango

extension PangoFontDescription: CNonReferableType {
    public var copyFunc: (UnsafePointer<PangoFontDescription>?) -> (UnsafeMutablePointer<PangoFontDescription>?) {
        return pango_font_description_copy
    }

    public var destroyFunc: (UnsafeMutablePointer<PangoFontDescription>?) -> () {
        pango_font_description_free
    }
}
