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

internal extension CairoGraphics.CGContext {
    convenience init(display: UnsafeMutablePointer<CX11.Display>, window: CX11.Window) {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display, window, &windowAttributes) == 0 {
            fatalError("Can not get window attributes")
        }
        #if os(Linux)
        let surface = cairo_xlib_surface_create(display, window, windowAttributes.visual, windowAttributes.width, windowAttributes.height)!
        self.init(surface: surface, size: CGSize(width: Int(windowAttributes.width), height: Int(windowAttributes.height)))
        cairo_surface_destroy(surface)
        #else
        fatalError("Running on non-Linux targets is not supported at the moment")
        #endif
    }
}
