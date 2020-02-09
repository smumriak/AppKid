//
//  CGContext.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 3/2/20.
//

import Foundation
import CCairo

open class CGContext {
    internal fileprivate(set) var _context: OpaquePointer
    public internal(set) var size: CGSize
    
    deinit {
        cairo_destroy(_context)
    }
    
    internal init(cairoContext: OpaquePointer, size: CGSize) {
        self._context = cairo_reference(cairoContext)
        self.size = size
    }
    
    public convenience init(surface: OpaquePointer, size: CGSize) {
        let context = cairo_create(surface)!
        self.init(cairoContext: context, size: size)
        cairo_destroy(context)
    }
}

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
    convenience init(_ context: CGContext) {
        self.init(cairoContext: context._context, size: context.size)
    }
    
    convenience init?(width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitMapInfo: CGBitmapInfo) {
        let surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, Int32(width), Int32(height))!
        self.init(surface: surface, size: CGSize(width: width, height: height))
        cairo_surface_destroy(surface)
    }
}
