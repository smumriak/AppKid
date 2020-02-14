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
    var surface: UnsafeMutablePointer<cairo_surface_t>
    var nativeWindow: X11NativeWindow
    
    deinit {
        #if os(Linux)
        surface.release()
        #endif
    }
    
    init(nativeWindow: X11NativeWindow) {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(nativeWindow.display, nativeWindow.windowID, &windowAttributes) == 0 {
            fatalError("Can not get window attributes")
        }
        #if os(Linux)
        surface = cairo_xlib_surface_create(nativeWindow.display, nativeWindow.windowID, windowAttributes.visual, windowAttributes.width, windowAttributes.height)!
        cairo_xlib_surface_set_size(surface, windowAttributes.width, windowAttributes.height)
        self.nativeWindow = nativeWindow
        
        super.init(surface: surface, size: CGSize(width: Int(windowAttributes.width), height: Int(windowAttributes.height)))
        #else
        fatalError("Running on non-Linux targets is not supported at the moment")
        #endif
    }

    func updateSurface(display: UnsafeMutablePointer<CX11.Display>, window: CX11.Window) {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display, window, &windowAttributes) == 0 {
            fatalError("Can not get window attributes")
        }
        #if os(Linux)
        cairo_xlib_surface_set_size(surface, windowAttributes.width, windowAttributes.height)
        #endif
    }
}
