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

fileprivate let kEnableXInput2 = true

internal class DisplayServer {
    var x11Context = X11Context()

    internal var display: UnsafeMutablePointer<CX11.Display>
    internal var screen: UnsafeMutablePointer<CX11.Screen>

    internal lazy var pollThread = Thread { self.pollForX11Events() }

    internal var runLoopSource: CFRunLoopSource? = nil

    lazy var displayScale: CGFloat = {
        if let gtkDisplayScale = gtkDisplayScale {
            return CGFloat(gtkDisplayScale)
        } else {
            return 1.0
        }
    }()

    internal let rootWindow: X11NativeWindow

    // MARK: Deinitialization

    deinit {
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

        if XQueryExtension(display, "XInputExtension".cString(using: .ascii), &x11Context.xInput2ExtensionOpcode, &event, &error) == 0 {
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

        rootWindow = X11NativeWindow(display: display, screen: screen, windowID: screen.pointee.root)

        rootWindow.displayScale = displayScale
    }
}

extension DisplayServer {
    func createNativeWindow(contentRect: CGRect) -> X11NativeWindow {
        var scaledContentRect = contentRect
        scaledContentRect.size.width *= displayScale
        scaledContentRect.size.height *= displayScale

        let intRect: Rect<CInt> = scaledContentRect.rect()
        let windowID = XCreateSimpleWindow(display, rootWindow.windowID, intRect.x, intRect.y, CUnsignedInt(intRect.width), CUnsignedInt(intRect.height), 1, screen.pointee.black_pixel, screen.pointee.white_pixel)

        if kEnableXInput2 {
            XSelectInput(display, windowID, Int(X11EventTypeMask.geometry.rawValue))

            var xInput2EventsMask = UInt32(XInput2EventTypeMask.basic.rawValue)

            withUnsafeMutablePointer(to: &xInput2EventsMask) {
                let reboundPointer = UnsafeMutableRawPointer($0).bindMemory(to: UInt8.self, capacity: 4)

                var xInput2EventMask = XIEventMask(deviceid: XIAllMasterDevices, mask_len: 4 , mask: reboundPointer)

                XISelectEvents(display, windowID, &xInput2EventMask, 1)
            }
        } else {
            XSelectInput(display, windowID, Int(X11EventTypeMask.basic.rawValue))
        }
        
        XMapWindow(display, windowID)
        XSetWMProtocols(display, windowID, &x11Context.wmDeleteWindowAtom, 1)

        let result: X11NativeWindow = X11NativeWindow(display: display, screen: screen, windowID: windowID)
        result.displayScale = displayScale

        result.flush()

        return result
    }
}
