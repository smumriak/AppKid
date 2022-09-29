//
//  X11DisplayServer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 25.08.2020.
//

import Foundation
import CoreFoundation
import TinyFoundation

import CXlib
import SwiftXlib

internal extension ProcessInfo {
    static let displayEnvironmentKey = "DISPLAY"
    static let forceScaleFactorEnvironmentKey = "APPKID_FORCE_SCALE_FACTOR"

    static var display: String? {
        get {
            processInfo.environment[displayEnvironmentKey]
        }
        set {
            if let newValue = newValue {
                setenv(displayEnvironmentKey, newValue, 1)
            } else {
                unsetenv(displayEnvironmentKey)
            }
        }
    }

    static var forceScaleFactor: String? {
        get {
            processInfo.environment[forceScaleFactorEnvironmentKey]
        }
        set {
            if let newValue = newValue {
                setenv(forceScaleFactorEnvironmentKey, newValue, 1)
            } else {
                unsetenv(forceScaleFactorEnvironmentKey)
            }
        }
    }
}

internal final class X11DisplayServer: DisplayServer {
    var context = X11DisplayServerContext()
    var eventQueueNotificationObserver: AnyObject?

    var nativeIdentifierToWindowNumber: [XID: Int] = [:]

    let applicationName: String

    let display: SwiftXlib.Display
    let screen: UnsafeMutablePointer<CXlib.Screen>

    var inputMethod: XIM?
    let inputStyle: XIMStyle?

    let rootWindow: X11NativeWindow

    internal var hasEvents = false

    // MARK: - Deinitialization

    deinit {
        inputMethod.map {
            _ = XCloseIM($0)
        }
    }

    // MARK: - Initialization

    init(applicationName appName: String) {
        XInitThreads()

        if ProcessInfo.display == nil {
            debugPrint("DISPLAY environment variable is not set. Setting it to :0")
            ProcessInfo.display = ":0"
        }

        guard let displayNumber = ProcessInfo.processInfo.environment["DISPLAY"] else {
            fatalError("DISPLAY environment variable is not set")
        }

        do {
            display = try SwiftXlib.Display(displayNumber)
        } catch {
            fatalError("Can not create display with error: \(error)")
        }

        screen = XDefaultScreenOfDisplay(display.pointer)
        applicationName = appName

        var rootWindowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display.pointer, screen.pointee.root, &rootWindowAttributes) == 0 {
            fatalError("Can not get root window attributes")
        }

        inputMethod = XOpenIM(display.pointer, nil, nil, nil)

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

        rootWindow = X11NativeWindow(display: display, screen: screen, windowIdentifier: screen.pointee.root, title: "root")

        if let forceScaleFactorString = ProcessInfo.forceScaleFactor, let forceScaleFactor = CGFloat(forceScaleFactorString) {
            context.scale = CGFloat(forceScaleFactor)
        } else {
            gtkDisplayScale.map {
                context.scale = CGFloat($0)
            }
        }

        rootWindow.displayScale = context.scale
    }

    func flush() {
        display.flush()
    }
}

extension X11DisplayServer {
    func createNativeWindow(contentRect: CGRect, title: String) -> X11NativeWindow {
        var scaledContentRect = contentRect
        scaledContentRect.size.width *= context.scale
        scaledContentRect.size.height *= context.scale

        let intRect: Rect<CInt> = scaledContentRect.rect()

        var attributesMask: UInt = 0
        var attributes = XSetWindowAttributes()

        // attributesMask |= UInt(CWBorderPixel)
        // attributes.border_pixel =  XBlackPixel(display.pointer, XDefaultScreen(display.pointer))

        // attributesMask |= UInt(CWBackPixel)
        // attributes.background_pixel = XWhitePixel(display.pointer, XDefaultScreen(display.pointer))

        // attributesMask |= UInt(CWBackPixmap)
        // attributes.background_pixmap = Pixmap(CXlib.None)

        // attributesMask |= UInt(CWOverrideRedirect)
        // attributes.override_redirect = 1

        let visual = XDefaultVisualOfScreen(screen)
        let depth = XDefaultDepthOfScreen(screen)
        let colorMap = XCreateColormap(display.pointer, rootWindow.windowIdentifier, visual, AllocNone)
        defer { XFreeColormap(display.pointer, colorMap) }

        attributesMask |= UInt(CWColormap)
        attributes.colormap = colorMap
        attributes.bit_gravity = StaticGravity

        let windowIdentifier = XCreateWindow(display.pointer,
                                             rootWindow.windowIdentifier,
                                             intRect.x, intRect.y,
                                             CUnsignedInt(intRect.width), CUnsignedInt(intRect.height),
                                             2,
                                             depth,
                                             CUnsignedInt(InputOutput),
                                             visual,
                                             attributesMask,
                                             &attributes)

        let result = X11NativeWindow(display: display, screen: screen, windowIdentifier: windowIdentifier, title: title)
        result.displayScale = context.scale

        XStoreName(display.pointer, windowIdentifier, title)

        let classHint = XAllocClassHint()
        defer { XFree(classHint) }

        applicationName.withCString {
            let mutableString = UnsafeMutablePointer(mutating: $0)
            classHint?.pointee.res_name = mutableString
            classHint?.pointee.res_class = mutableString

            XSetClassHint(display.pointer, windowIdentifier, classHint)
        }

        var atoms: [CXlib.Atom] = [
            display.knownAtom(.deleteWindow),
            display.knownAtom(.takeFocus),
            display.knownAtom(.syncRequest),
        ]
        atoms.withUnsafeMutableBufferPointer {
            let _ = XSetWMProtocols(display.pointer, windowIdentifier, $0.baseAddress!, CInt($0.count))
        }

        let value: Int = 2
                
        result.window.set(property: display.knownAtom(.bypassCompositor), type: XA_CARDINAL, format: .thirtyTwo, value: value)

        result.updateListeningEvents(displayServer: self)
        result.map(displayServer: self)

        if let inputMethod = inputMethod, let inputStyle = inputStyle {
            result.inputContext = XCreateInputContext(inputMethod, inputStyle, result.windowIdentifier)
        }

        flush()

        return result
    }
}
