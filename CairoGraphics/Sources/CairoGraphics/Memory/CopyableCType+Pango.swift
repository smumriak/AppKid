//
//  CopyableCType+Pango.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.02.2020.
//

import Foundation
import CPango
import TinyFoundation

extension PangoFontDescription: CopyableCType {
    public static var copyFunc: (UnsafePointer<PangoFontDescription>?) -> (UnsafeMutablePointer<PangoFontDescription>?) {
        return pango_font_description_copy
    }

    public static var releaseFunc: (UnsafeMutablePointer<PangoFontDescription>?) -> () {
        pango_font_description_free
    }
}
