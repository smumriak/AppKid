//
//  CGContext+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import CXlib
@_spi(AppKid) import CairoGraphics
import CCairo
import TinyFoundation

#if os(macOS)
import class CairoGraphics.CGContext
#endif

internal class X11RenderContext: CGContext {
    var nativeWindow: X11NativeWindow
    
    init(nativeWindow: X11NativeWindow) {
        let windowAttributes = nativeWindow.attributes
        #if os(Linux)
            let surface = cairo_xlib_surface_create(nativeWindow.display.handle, nativeWindow.windowID, windowAttributes.visual, windowAttributes.width, windowAttributes.height)!

            self.nativeWindow = nativeWindow
        
            super.init(surface: RetainablePointer(withRetained: surface), width: Int(windowAttributes.width), height: Int(windowAttributes.height))
        #else
            fatalError("Running on non-Linux targets is not supported at the moment")
        #endif
    }

    func updateSurface() {
        #if os(Linux)
            let currentRect = nativeWindow.currentIntRect
            cairo_xlib_surface_set_size(surface, currentRect.width, currentRect.height)
        #endif
    }
}
