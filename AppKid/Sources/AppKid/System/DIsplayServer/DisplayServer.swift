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

internal class DisplayServer: NSObject {
    var context = DisplayServerContext()

    let applicationName: String

    let display: UnsafeMutablePointer<CX11.Display>
    let screen: UnsafeMutablePointer<CX11.Screen>

    var inputMethod: XIM?
    let inputStyle: XIMStyle?

    lazy var pollThread = Thread { self.pollForX11Events() }

    var runLoopSource: CFRunLoopSource? = nil

    let rootWindow: X11NativeWindow

    // MARK: Deinitialization

    deinit {
        inputMethod.map {
            _ = XCloseIM($0)
        }

        XCloseDisplay(display)
    }

    // MARK: Initialization

    init(applicationName appName: String) {
        guard let openDisplay = XOpenDisplay(nil) ?? XOpenDisplay(":0") else {
            fatalError("Could not open X display.")
        }

        display = openDisplay
        screen = XDefaultScreenOfDisplay(display)
        applicationName = appName

        var event: CInt = 0
        var error: CInt = 0

        if XSyncQueryExtension(display, &event, &error) == 0 {
            XCloseDisplay(display)
            fatalError("XSync exntension is not available")
        }

        var xSyncMajorVersion: CInt = 3
        var xSyncMinorVersion: CInt = 1
        if XSyncInitialize(display, &xSyncMajorVersion, &xSyncMinorVersion) == 0 {
            XCloseDisplay(display)
            fatalError("XSync is not available.")
        }

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

        rootWindow = X11NativeWindow(display: display, screen: screen, windowID: screen.pointee.root, title: "root")

        super.init()

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
    func createNativeWindow(contentRect: CGRect, title: String) -> X11NativeWindow {
        var scaledContentRect = contentRect
        scaledContentRect.size.width *= context.scale
        scaledContentRect.size.height *= context.scale

        let intRect: Rect<CInt> = scaledContentRect.rect()

        var attributesMask: UInt = 0
        var attributes = XSetWindowAttributes()

//        attributesMask |= UInt(CWBorderPixel)
//        attributes.border_pixel = 0

//        attributesMask |= UInt(CWBackPixel)
//        attributes.background_pixel = UInt.max

        let visual = XDefaultVisualOfScreen(screen)
        let depth = XDefaultDepthOfScreen(screen)
        let colorMap = XCreateColormap(display, rootWindow.windowID, visual, AllocNone)
        defer { XFreeColormap(display, colorMap) }

        attributesMask |= UInt(CWColormap)
        attributes.colormap = colorMap

        let windowID = XCreateWindow(display,
                                     rootWindow.windowID,
                                     intRect.x, intRect.y,
                                     CUnsignedInt(intRect.width), CUnsignedInt(intRect.height),
                                     2,
                                     depth,
                                     CUnsignedInt(InputOutput),
                                     visual,
                                     attributesMask,
                                     &attributes)

        let syncValue = XSyncValue(hi: 0, lo: 0)
        let basicSyncCounter = XSyncCreateCounter(display, syncValue)
        let extendedSyncCounter = XSyncCreateCounter(display, syncValue)

        let result: X11NativeWindow = X11NativeWindow(display: display, screen: screen, windowID: windowID, title: title)
        result.displayScale = context.scale
        result.syncCounter = (basicSyncCounter, extendedSyncCounter)

        XStoreName(display, windowID, title)

        let classHint = XAllocClassHint()
        defer { XFree(classHint) }

        applicationName.withCString {
            let mutableString = UnsafeMutablePointer(mutating: $0)
            classHint?.pointee.res_name = mutableString
            classHint?.pointee.res_class = mutableString

            XSetClassHint(display, windowID, classHint)
        }

        var atoms: [Atom] = [
            context.deleteWindowAtom,
//            context.takeFocusAtom,
            context.syncRequestAtom,
        ]
        atoms.withUnsafeMutableBufferPointer {
            let _ = XSetWMProtocols(display, windowID, $0.baseAddress!, CInt($0.count))
        }

        result.updateListeningEvents(displayServer: self)
        result.map(displayServer: self)

        if let inputMethod = inputMethod, let inputStyle = inputStyle {
            result.inputContext = XCreateInputContext(inputMethod, inputStyle, result.windowID)
        }

        flush()

        return result
    }
}
