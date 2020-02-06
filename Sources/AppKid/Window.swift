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
    internal var display: UnsafeMutablePointer<CX11.Display>
    internal var screen: UnsafeMutablePointer<CX11.Screen>
    internal var x11Window: CX11.Window
    
    deinit {
        XDestroyWindow(display, x11Window)
    }
    
    internal init(x11Window: CX11.Window, display: UnsafeMutablePointer<CX11.Display>, screen: UnsafeMutablePointer<CX11.Screen>) {
        self.x11Window = x11Window
        self.display = display
        self.screen = screen
    }
    
    convenience init(contentRect: CGRect) {
        let display = Application.shared.display.display
        let screen = Application.shared.display.screen
           
        let rootWindow = Application.shared.display.rootWindow
        let x11Window = XCreateSimpleWindow(display, rootWindow.x11Window, Int32(contentRect.minX), Int32(contentRect.minY), UInt32(contentRect.width), UInt32(contentRect.height), 1, screen.pointee.black_pixel, screen.pointee.white_pixel)
        
        XSelectInput(display, x11Window, Event.EventType.x11EventMask())
        XMapWindow(display, x11Window)
        XSetWMProtocols(display, x11Window, &Application.shared.display.wmDeleteWindowAtom, 1);
        XFlush(display)
        
        self.init(x11Window: x11Window, display: display, screen: screen)
    }
    
    public func post(event: Event, atStart: Bool) {
        Application.shared.post(event: event, atStart: atStart)
    }
    
    public func send(event: Event) {
        switch event.type {
        case .leftMouseDown, .leftMouseDragged:
            let blackColor = XBlackPixelOfScreen(screen)
            XSetForeground(display, screen.pointee.default_gc, blackColor)
            XFillRectangle(display, x11Window, screen.pointee.default_gc, Int32(event.locationInWindow.x - 10.0), Int32(event.locationInWindow.y - 10.0), 20, 20)
            XSync(display, 0)
            
        case .rightMouseDown, .rightMouseDragged:
            let blackColor = XWhitePixelOfScreen(screen)
            XSetForeground(display, screen.pointee.default_gc, blackColor)
            XFillRectangle(display, x11Window, screen.pointee.default_gc, Int32(event.locationInWindow.x - 10.0), Int32(event.locationInWindow.y - 10.0), 20, 20)
            XSync(display, 0)
            
        case .leftMouseUp:
            let whiteColor = XWhitePixelOfScreen(screen)
            XSetForeground(display, screen.pointee.default_gc, whiteColor)
            XFillRectangle(display, x11Window, screen.pointee.default_gc, Int32(event.locationInWindow.x - 10.0), Int32(event.locationInWindow.y - 10.0), 20, 20)
            XSync(display, 0)
        default:
            break
        }
    }
}

extension Window: Equatable {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return lhs.x11Window == rhs.x11Window
    }
}
