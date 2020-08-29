//
//  CGContext+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import CXlib
import CairoGraphics
import CCairo
import TinyFoundation

internal class X11RenderContext: CairoGraphics.CGContext {
    var surfacePointer: RetainablePointer<cairo_surface_t>
    var surface: UnsafeMutablePointer<cairo_surface_t> {
        get {
            return surfacePointer.pointer
        }
        set {
            surfacePointer.pointer = newValue
        }
    }

    var nativeWindow: X11NativeWindow
    
    init(nativeWindow: X11NativeWindow) {
        let windowAttributes = nativeWindow.attributes
        #if os(Linux)
            let surface = cairo_xlib_surface_create(nativeWindow.display, nativeWindow.windowID, windowAttributes.visual, windowAttributes.width, windowAttributes.height)!
            surfacePointer = RetainablePointer(withRetained: surface)

            self.nativeWindow = nativeWindow
        
            super.init(surface: surface, size: CGSize(width: Int(windowAttributes.width), height: Int(windowAttributes.height)))
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
