//
//  CGBitmapContext.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import TinyFoundation
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
    enum CGImageAlphaInfo: UInt32 {
        case first = 4
        case last = 3
        case none = 0
        case noneSkipFirst = 6
        case alphaOnly = 7
        case noneSkipLast = 5
        case premultipliedFirst = 2
        case premultipliedLast = 1
    }
}

public extension CGContext {
    convenience init?(data: UnsafeMutableRawPointer? = nil, width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitMapInfo: CGBitmapInfo) {
        let bitmapData: UnsafeMutableRawPointer?
        let surfaceRaw: UnsafeMutablePointer<cairo_surface_t>
        if let data = data {
            let rebound = data.assumingMemoryBound(to: UInt8.self)
            let stride = cairo_format_stride_for_width(.argb32, CInt(width))
            surfaceRaw = cairo_image_surface_create_for_data(rebound, .argb32, CInt(width), CInt(height), stride)!
            bitmapData = data
        } else {
            surfaceRaw = cairo_image_surface_create(.argb32, CInt(width), CInt(height))!
            bitmapData = UnsafeMutableRawPointer(cairo_image_surface_get_data(surfaceRaw))
        }

        let surface = RetainablePointer(withRetained: surfaceRaw)

        self.init(surface: surface, width: width, height: height)
        self.dataStore = CGContextDataStore(surface: surface)
    }
}
