//
//  Window.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation
import CX11.Xlib
import CX11.X

open class Window {
    internal var display: Application.Display
    internal var x11Window: CX11.Window
    
    deinit {
        XDestroyWindow(display, x11Window)
    }
    
    internal init(x11Window: CX11.Window, display: Application.Display = Application.shared.display) {
        self.x11Window = x11Window
        self.display = display
    }
    
    convenience init(contentRect: CGRect) {
        let display = Application.shared.display
        let screen = Application.shared.screen
           
        let rootWindow = Application.shared.rootWindow
        let x11Window = XCreateSimpleWindow(display, rootWindow.x11Window, Int32(contentRect.minX), Int32(contentRect.minY), UInt32(contentRect.width), UInt32(contentRect.height), 1, screen.pointee.black_pixel, screen.pointee.white_pixel)
        
        XSelectInput(display, x11Window, EventType.x11EventMask())
        XMapWindow(display, x11Window)
        XSetWMProtocols(display, x11Window, &Application.shared.x11WMDeleteWindowAtom, 1);
        XFlush(display)
        
        self.init(x11Window: x11Window)
    }
}

extension Window: Equatable {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return lhs.x11Window == rhs.x11Window
    }
}
