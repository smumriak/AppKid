//
//  Window.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation
import CX11.Xlib
import CX11.X
import CairoGraphics

open class Window: View {
    internal var _display: UnsafeMutablePointer<CX11.Display>
    internal var _screen: UnsafeMutablePointer<CX11.Screen>
    internal var _x11Window: CX11.Window
    internal var _windowNumber: Int { Int(_x11Window) }
    internal var _graphicsContext: CairoGraphics.CGContext
    
    override public var window: Window? {
        get { return self }
        set {}
    }
    
    deinit {
        XDestroyWindow(_display, _x11Window)
    }
    
    internal init(x11Window: CX11.Window, display: UnsafeMutablePointer<CX11.Display>, screen: UnsafeMutablePointer<CX11.Screen>, contentRect: CGRect = .zero) {
        _x11Window = x11Window
        _display = display
        _screen = screen
        
        _graphicsContext = CairoGraphics.CGContext(display: display, window: x11Window)
        
        super.init(with: contentRect)
    }
    
    convenience init(contentRect: CGRect) {
        let display = Application.shared.display
        let screen = Application.shared.screen
        let rootWindow = Application.shared.rootWindow
        
        let x11Window = XCreateSimpleWindow(display, rootWindow._x11Window, Int32(contentRect.minX), Int32(contentRect.minY), UInt32(contentRect.width), UInt32(contentRect.height), 1, screen.pointee.black_pixel, screen.pointee.white_pixel)
        
        XSelectInput(display, x11Window, Event.EventType.x11EventMask())
        XMapWindow(display, x11Window)
        XSetWMProtocols(display, x11Window, &Application.shared.wmDeleteWindowAtom, 1);
        XFlush(display)
        
        self.init(x11Window: x11Window, display: display, screen: screen, contentRect: contentRect)
    }
    
    public func post(event: Event, atStart: Bool) {
        Application.shared.post(event: event, atStart: atStart)
    }
    
    public func send(event: Event) {
        switch event.type {
        case .leftMouseDown, .leftMouseDragged:
            let blackColor = XBlackPixelOfScreen(_screen)
            XSetForeground(_display, _screen.pointee.default_gc, blackColor)
            XFillRectangle(_display, _x11Window, _screen.pointee.default_gc, Int32(event.locationInWindow.x - 10.0), Int32(event.locationInWindow.y - 10.0), 20, 20)
            XSync(_display, 0)
            
        case .rightMouseDown, .rightMouseDragged:
            let blackColor = XWhitePixelOfScreen(_screen)
            XSetForeground(_display, _screen.pointee.default_gc, blackColor)
            XFillRectangle(_display, _x11Window, _screen.pointee.default_gc, Int32(event.locationInWindow.x - 10.0), Int32(event.locationInWindow.y - 10.0), 20, 20)
            XSync(_display, 0)
            
        case .leftMouseUp:
            let whiteColor = XWhitePixelOfScreen(_screen)
            XSetForeground(_display, _screen.pointee.default_gc, whiteColor)
            XFillRectangle(_display, _x11Window, _screen.pointee.default_gc, Int32(event.locationInWindow.x - 10.0), Int32(event.locationInWindow.y - 10.0), 20, 20)
            XSync(_display, 0)

        default:
            break
        }
    }
    
    public override func draw(in rect: CGRect) {
        CairoGraphics.CGContext.push(_graphicsContext)
        // missing convert
        super.draw(in: rect)
        CairoGraphics.CGContext.pop()
    }
}

extension Window {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return lhs === rhs || lhs._x11Window == rhs._x11Window
    }
}
