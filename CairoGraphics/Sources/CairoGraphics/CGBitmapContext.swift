//
//  CGBitmapContext.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import TinyFoundation
import CCairo

@_spi(AppKid) public protocol CGBitmapInfoConvertible: RawRepresentable {
    static var mask: CGContext.CGBitmapInfo { get }
}


@_spi(AppKid) extension CGContext.CGImageAlphaInfo: CGBitmapInfoConvertible {}

@_spi(AppKid) extension CGContext.CGImagePixelFormatInfo: CGBitmapInfoConvertible {}

public extension CGBitmapInfoConvertible where RawValue == CGContext.CGBitmapInfo.RawValue {
    var bitmapInfo: CGContext.CGBitmapInfo {
        return CGContext.CGBitmapInfo(rawValue: self.rawValue)
    }

    init(bitmapInfo: CGContext.CGBitmapInfo) {
        self.init(rawValue: bitmapInfo.intersection(Self.mask).rawValue)!
    }
}

public extension CGContext {
    struct CGBitmapInfo: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    enum CGImageAlphaInfo: UInt {
        case none = 0 //RBG
        case premultipliedLast = 1 //RGBA
        case premultipliedFirst = 2 //ARGB
        case last = 3 //RGBA non-premultiplied
        case first = 4 //ARGB non-premultiplied
        case noneSkipLast = 5 //RGBx
        case noneSkipFirst = 6 //xRGB
        case alphaOnly = 7 // alpha

        public static let mask = CGBitmapInfo(rawValue: 0x1F)
    }

    enum CGImagePixelFormatInfo: UInt {
        case packed = 0x00000 //0 << 16
        case rgb555 = 0x10000 //1 << 16
        case rgb565 = 0x20000 //2 << 16
        case rgb101010 = 0x30000 //3 << 16
        case rgbcif10 = 0x40000 //4 << 16

        public static let mask = CGBitmapInfo(rawValue: 0xF0000)
    }
}

public extension CGContext {
    convenience init?(data: UnsafeMutableRawPointer? = nil, width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, colorSpace: CGColorSpace, bitmapInfo: CGBitmapInfo) {
        let format = cairo_format_t(bitsPerComponent: bitsPerComponent, bitmapInfo: bitmapInfo)

        if format == .invalid {
            return nil
        }

        let surfaceRaw: UnsafeMutablePointer<cairo_surface_t>
        if let data = data {
            let rebound = data.assumingMemoryBound(to: UInt8.self)
            surfaceRaw = cairo_image_surface_create_for_data(rebound, format, CInt(width), CInt(height), format.stride(width: width))!
        } else {
            surfaceRaw = cairo_image_surface_create(format, CInt(width), CInt(height))!
        }

        let surface = RetainablePointer(withRetained: surfaceRaw)

        self.init(surface: surface, width: width, height: height)
        self.dataStore = CGContextDataStore(surface: surface)

        self.width = width
        self.height = height
        self.bitsPerComponent = bitsPerComponent
        self.bytesPerRow = bytesPerRow
        self.colorSpace = colorSpace
        self.bitmapInfo = bitmapInfo
    }
}
