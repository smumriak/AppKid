//
//  CGContext+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 8/2/20.
//

import Foundation
import CX11.Xlib
import CX11.X
import CairoGraphics
import CCairo

internal class X11RenderContext: CairoGraphics.CGContext {
    var surfacePointer: CReferablePointer<cairo_surface_t>
    var surface: UnsafeMutablePointer<cairo_surface_t> {
        get {
            return surfacePointer.pointer
        }
        set {
            surfacePointer = CReferablePointer(with: newValue)
        }
    }
    var nativeWindow: X11NativeWindow
    
    init(nativeWindow: X11NativeWindow) {
        let windowAttributes = nativeWindow.attributes
        #if os(Linux)
        let surface = cairo_xlib_surface_create(nativeWindow.display, nativeWindow.windowID, windowAttributes.visual, windowAttributes.width, windowAttributes.height)!
        surfacePointer = CReferablePointer(with: surface)
        surface.release()

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
