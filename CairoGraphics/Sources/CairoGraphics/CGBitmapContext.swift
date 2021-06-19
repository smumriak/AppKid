//
//  CGBitmapContext.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import CCairo

public extension CGContext {
    struct CGBitmapInfo: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

public extension CGContext {
    convenience init?(width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitMapInfo: CGBitmapInfo) {
        let surface = cairo_image_surface_create(.argb32, CInt(width), CInt(height))!
        self.init(surface: surface, size: CGSize(width: width, height: height))
        cairo_surface_destroy(surface)
    }
}
