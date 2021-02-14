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

internal final class X11DisplayServer: NSObject, DisplayServer {
    var context = X11DisplayServerContext()
    var eventQueueNotificationObserver: NSObjectProtocol?

    let applicationName: String

    let display: SwiftXlib.Display
    let screen: UnsafeMutablePointer<CXlib.Screen>

    var inputMethod: XIM?
    let inputStyle: XIMStyle?

    let rootWindow: X11NativeWindow

    internal var hasEvents = false

    // MARK: Deinitialization

    deinit {
        inputMethod.map {
            _ = XCloseIM($0)
        }
    }

    // MARK: Initialization

    init(applicationName appName: String) {
        XInitThreads()
        do {
            display = try SwiftXlib.Display()
        } catch {
            fatalError("Can not create display with error: \(error)")
        }

        screen = XDefaultScreenOfDisplay(display.handle)
        applicationName = appName

        var rootWindowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display.handle, screen.pointee.root, &rootWindowAttributes) == 0 {
            fatalError("Can not get root window attributes")
        }

        inputMethod = XOpenIM(display.handle, nil, nil, nil)

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
        // attributes.border_pixel = 0

        // attributesMask |= UInt(CWBackPixel)
        // attributes.background_pixel = UInt.max

        // attributesMask |= UInt(CWOverrideRedirect)
        // attributes.override_redirect = 1

        let visual = XDefaultVisualOfScreen(screen)
        let depth = XDefaultDepthOfScreen(screen)
        let colorMap = XCreateColormap(display.handle, rootWindow.windowID, visual, AllocNone)
        defer { XFreeColormap(display.handle, colorMap) }

        attributesMask |= UInt(CWColormap)
        attributes.colormap = colorMap

        let windowID = XCreateWindow(display.handle,
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
        let basicSyncCounter = XSyncCreateCounter(display.handle, syncValue)
        let extendedSyncCounter = XSyncCreateCounter(display.handle, syncValue)

        let result = X11NativeWindow(display: display, screen: screen, windowID: windowID, title: title)
        result.displayScale = context.scale
        result.syncCounter = (basicSyncCounter, extendedSyncCounter)

        XStoreName(display.handle, windowID, title)

        let classHint = XAllocClassHint()
        defer { XFree(classHint) }

        applicationName.withCString {
            let mutableString = UnsafeMutablePointer(mutating: $0)
            classHint?.pointee.res_name = mutableString
            classHint?.pointee.res_class = mutableString

            XSetClassHint(display.handle, windowID, classHint)
        }

        var atoms: [Atom] = [
            display.deleteWindowAtom,
            display.takeFocusAtom,
            display.syncRequestAtom,
        ]
        atoms.withUnsafeMutableBufferPointer {
            let _ = XSetWMProtocols(display.handle, windowID, $0.baseAddress!, CInt($0.count))
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
