//
//  CGBitmapContext.swift
//  AppKid
//
//  Created by Serhii Mumriak on 8/2/20.
//

import Foundation
import CCairo

public extension CGContext {
    struct CGBitmapInfo: OptionSet {
        public typealias RawValue = UInt32
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

public extension CGContext {
    convenience init?(width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitMapInfo: CGBitmapInfo) {
        let surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, Int32(width), Int32(height))!
        self.init(surface: surface, size: CGSize(width: width, height: height))
        cairo_surface_destroy(surface)
    }
}
