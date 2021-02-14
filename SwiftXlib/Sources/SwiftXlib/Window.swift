//
//  Window.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation
import TinyFoundation
import CXlib

public final class Window: NSObject {
    public let display: Display
    public let screen: Screen
    public let rootWindow: Window?
    public let windowID: CXlib.Window
    public let destroyOnDeinit: Bool
    
    deinit {
        if destroyOnDeinit {
            XDestroyWindow(display.handle, windowID)
        }
    }

    public init(display: Display, screen: Screen, rootWindow: Window? = nil, windowID: CXlib.Window, destroyOnDeinit: Bool = true) {
        self.display = display
        self.screen = screen
        self.rootWindow = rootWindow
        self.windowID = windowID
        self.destroyOnDeinit = false

        super.init()
    }

    // public convenience init(rootWindow: Window, )

    public enum PropertyType {
        case eight
        case sixteen
        case thirtyTwo

        internal var bitCount: CInt {
            switch self {
            case .eight: return 8 // data is a sequence of bytes, i.e. 8 bit array
            case .sixteen: return 16 // data is a sequence of shorts, i.e. 16 bit array
            case .thirtyTwo: return 32 // data is a sequence of longs, i.e. 32 bit array on 32 bit systems, 64 bit array on 64 bit systems. fuck you X11
            }
        }

        internal var byteCount: CInt {
            switch self {
            case .eight: return 1
            case .sixteen: return 2
            case .thirtyTwo:
                #if arch(i386) || arch(arm)
                    return 4
                #else
                    return 8
                #endif
            }
        }
    }

    public func set<T>(property: Atom, type: Atom, format: PropertyType, mode: XlibPropertyChangeMode = .replace, value: T) throws {
        let size = MemoryLayout.size(ofValue: value)
        
        withUnsafeBytes(of: value) { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            _ = XChangeProperty(display.handle, windowID, property, type, format.bitCount, mode.rawValue, buffer.baseAddress, CInt(size) / format.byteCount)
        }
    }

    public func set<T>(property: Atom, type: Atom, format: PropertyType, mode: XlibPropertyChangeMode = .replace, value: [T]) throws {
        value.withUnsafeBytes { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            _ = XChangeProperty(display.handle, windowID, property, type, format.bitCount, mode.rawValue, buffer.baseAddress, CInt(value.count))
        }
    }
}

public extension Rect where StorageType == CInt {
    init(x11WindowAttributes windowAttributes: XWindowAttributes) {
        self.init(x: windowAttributes.x, y: windowAttributes.y, width: windowAttributes.width, height: windowAttributes.height)
    }
}
