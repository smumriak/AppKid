//
//  X11WindowInfo.swift
//  AppKid
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation
import CX11.Xlib
import CX11.X

internal final class X11NativeWindow {
    fileprivate(set) var display: UnsafeMutablePointer<CX11.Display>
    fileprivate(set) var screen: UnsafeMutablePointer<CX11.Screen>
    fileprivate(set) var windowID: CX11.Window
    
    var attributes: XWindowAttributes {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display, windowID, &windowAttributes) == 0 {
            fatalError("Can not get window attributes for window with ID: \(windowID)")
        }
        return windowAttributes
    }

    var currentRect: CGRect {
        return currentIntRect.cgRect
    }
    
    var currentIntRect: Rect<CInt> {
        return Rect<CInt>(x11WindowAttributes: attributes)
    }

    var isRoot: Bool {
        return screen.pointee.root == windowID
    }

    var acceptsMouseMovedEvents: Bool = false
//    {
//        didSet {
//            var mask = X11EventTypeMask.basic
//            if acceptsMouseMovedEvents {
//                mask.formUnion(.pointerMotion)
//            }
//
//            XSelectInput(display, windowID, Int(mask.rawValue))
//
//            flush()
//        }
//    }
    
    deinit {
        if !isRoot {
            // checking if this is not a root window. root window has rootWindowID as nil
            XDestroyWindow(display, windowID)
            flush()
        }
    }

    var displayScale: CGFloat = 1.0
    
    internal init(display: UnsafeMutablePointer<CX11.Display>, screen: UnsafeMutablePointer<CX11.Screen>, windowID: CX11.Window) {
        self.display = display
        self.screen = screen
        self.windowID = windowID
    }

    func flush() {
        XFlush(display)
    }
}

extension X11NativeWindow: Equatable {
    static func == (lhs: X11NativeWindow, rhs: X11NativeWindow) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs) || lhs.windowID == rhs.windowID
    }
}

internal struct Rect<StorageType> where StorageType: BinaryInteger {
    var x: StorageType
    var y: StorageType
    var width: StorageType
    var height: StorageType
}

extension Rect where StorageType == CInt {
    init(x11WindowAttributes windowAttributes: XWindowAttributes) {
        self.init(x: windowAttributes.x, y: windowAttributes.y, width: windowAttributes.width, height: windowAttributes.height)
    }
}

extension Rect {
    var cgRect: CGRect {
        return CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
    }
}

internal extension CGRect{
    func rect<StorageType>() -> Rect<StorageType> where StorageType: BinaryInteger {
        let standardized = self.standardized
        return Rect<StorageType>(x: StorageType(standardized.origin.x), y: StorageType(standardized.origin.y), width: StorageType(standardized.width), height: StorageType(standardized.height))
    }
}
