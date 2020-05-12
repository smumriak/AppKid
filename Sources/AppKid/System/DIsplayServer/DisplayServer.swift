//
//  DisplayServer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.04.2020.
//

import Foundation
import CoreFoundation

import CX11.Xlib
import CX11.X
import CXInput2

#if os(Linux)
import CEpoll
import Glibc
#endif

internal let kEnableXInput2 = true

internal class DisplayServer {
    var context = DisplayServerContext()

    internal let display: UnsafeMutablePointer<CX11.Display>
    internal let screen: UnsafeMutablePointer<CX11.Screen>

    internal var inputMethod: XIM?
    internal let inputStyle: XIMStyle?

    internal lazy var pollThread = Thread { self.pollForX11Events() }

    internal var runLoopSource: CFRunLoopSource? = nil

    internal let rootWindow: X11NativeWindow

    // MARK: Deinitialization

    deinit {
        inputMethod.map {
            _ = XCloseIM($0)
        }

        XCloseDisplay(display)
    }

    // MARK: Initialization

    init() {
        guard let openDisplay = XOpenDisplay(nil) ?? XOpenDisplay(":0") else {
            fatalError("Could not open X display.")
        }
        display = openDisplay
        screen = XDefaultScreenOfDisplay(display)

        var event: CInt = 0
        var error: CInt = 0

        if XQueryExtension(display, "XInputExtension".cString(using: .ascii), &context.xInput2ExtensionOpcode, &event, &error) == 0 {
            XCloseDisplay(display)
            fatalError("No XInputExtension available")
        }

        var xInputMajorVersion: CInt = 2
        var xInputMinorVersion: CInt = 0
        if XIQueryVersion(display, &xInputMajorVersion, &xInputMinorVersion) == BadRequest {
            XCloseDisplay(display)
            fatalError("XInput2 is not available.")
        }

        var rootWindowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display, screen.pointee.root, &rootWindowAttributes) == 0 {
            XCloseDisplay(display)
            fatalError("Can not get root window attributes")
        }

        inputMethod = XOpenIM(display, nil, nil, nil)

        inputStyle = inputMethod.flatMap {
            var stylesOptional: UnsafeMutablePointer<XIMStyles>? = nil

            XGetInputMethodStyles($0, &stylesOptional)
            defer {
                stylesOptional.map {
                    _ = XFree($0)
                }
            }

            guard let styles = stylesOptional, let supportedStyles = styles.pointee.supported_styles else {
                return nil
            }

            for i in 0..<Int(styles.pointee.count_styles) {
                let style = supportedStyles + i
                if style.pointee == XIMPreeditNothing | XIMStatusNothing {
                    return style.pointee
                }
            }

            return nil
        }

        if inputStyle == nil {
            inputMethod.map {
                _ = XCloseIM($0)
            }
            
            inputMethod = nil
        }

        rootWindow = X11NativeWindow(display: display, screen: screen, windowID: screen.pointee.root)

        gtkDisplayScale.map {
            context.scale = CGFloat($0)
        }

        rootWindow.displayScale = context.scale
    }

    func flush() {
        XFlush(display)
    }
}

extension DisplayServer {
    func createNativeWindow(contentRect: CGRect) -> X11NativeWindow {
        var scaledContentRect = contentRect
        scaledContentRect.size.width *= context.scale
        scaledContentRect.size.height *= context.scale

        let intRect: Rect<CInt> = scaledContentRect.rect()
        let windowID = XCreateSimpleWindow(display, rootWindow.windowID, intRect.x, intRect.y, CUnsignedInt(intRect.width), CUnsignedInt(intRect.height), 1, screen.pointee.black_pixel, screen.pointee.white_pixel)

        let result: X11NativeWindow = X11NativeWindow(display: display, screen: screen, windowID: windowID)
        result.displayScale = context.scale

        XSetStandardProperties(display, windowID, "Window", nil, 0, nil, 0, nil)

        result.updateListeningEvents(displayServer: self)
        result.map(displayServer: self)

        if let inputMethod = inputMethod, let inputStyle = inputStyle {
            result.inputContext = XCreateInputContext(inputMethod, inputStyle, result.windowID)
        }

        flush()

        return result
    }
}
