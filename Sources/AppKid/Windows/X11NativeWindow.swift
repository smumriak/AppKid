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

    var acceptsMouseMovedEvents: Bool = false {
        didSet {
            if !kEnableXInput2 {
                var mask = X11EventTypeMask.basic
                if acceptsMouseMovedEvents {
                    mask.formUnion(.pointerMotion)
                }

                XSelectInput(display, windowID, Int(mask.rawValue))

                flush()
            }
        }
    }

    var displayScale: CGFloat = 1.0

    var inputContext: XIC? = nil
    
    deinit {
        if !isRoot {
            XDestroyWindow(display, windowID)
            flush()
        }
    }
    
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
    var origin: Point<StorageType>
    var size: Size<StorageType>

    var x: StorageType {
        get { origin.x }
        set { origin.x = newValue }
    }
    var y: StorageType {
        get { origin.y }
        set { origin.y = newValue}
    }
    var width: StorageType {
        get { size.width }
        set { size.width = newValue }
    }
    var height: StorageType {
        get { size.height }
        set { size.height = newValue }
    }

    init(origin: Point<StorageType>, size: Size<StorageType>) {
        self.origin = origin
        self.size = size
    }

    init(x: StorageType, y: StorageType, width: StorageType, height: StorageType) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

internal struct Point<StorageType> where StorageType: BinaryInteger {
    var x: StorageType
    var y: StorageType
}

internal struct Size<StorageType> where StorageType: BinaryInteger {
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
        return CGRect(origin: origin.cgPoint, size: size.cgSize)
    }
}

internal extension CGRect{
    func rect<StorageType>() -> Rect<StorageType> where StorageType: BinaryInteger {
        let standardized = self.standardized
        return Rect(origin: standardized.origin.point(), size: standardized.size.size())
    }
}

extension Point {
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

extension CGPoint {
    func point<StorageType>() -> Point<StorageType> where StorageType: BinaryInteger {
        return Point(x: StorageType(x), y: StorageType(y))
    }
}

extension Size {
    var cgSize: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}

extension CGSize {
    func size<StorageType>() -> Size<StorageType> where StorageType: BinaryInteger {
        return Size(width: StorageType(width), height: StorageType(height))
    }
}
