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
    var surface: OpaquePointer
    
    deinit {
        // do not destroy surface here - cairo context will do that for you it CGContext's deinit
        #if os(Linux)
        cairo_surface_destroy(surface)
        #endif
    }
    
    init(display: UnsafeMutablePointer<CX11.Display>, window: CX11.Window) {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display, window, &windowAttributes) == 0 {
            fatalError("Can not get window attributes")
        }
        #if os(Linux)
        surface = cairo_xlib_surface_create(display, window, windowAttributes.visual, windowAttributes.width, windowAttributes.height)!
//        cairo_xlib_surface_set_size(surface, windowAttributes.width, windowAttributes.height)
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
