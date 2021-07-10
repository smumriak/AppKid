//
//  Window.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation
import TinyFoundation
import CXlib

public class Window: NSObject {
    public let display: Display
    public let screen: Screen
    public let rootWindow: RootWindow?
    public let windowID: CXlib.Window
    public let destroyOnDeinit: Bool
    
    deinit {
        if syncCounter.basic != XSyncCounter(None) {
            XSyncDestroyCounter(display.handle, syncCounter.basic)
        }

        if syncCounter.extended != XSyncCounter(None) {
            XSyncDestroyCounter(display.handle, syncCounter.extended)
        }
        
        if destroyOnDeinit {
            XDestroyWindow(display.handle, windowID)
        }
    }

    internal init(display: Display, screen: Screen, rootWindow: RootWindow?, windowID: CXlib.Window, destroyOnDeinit: Bool) {
        self.display = display
        self.screen = screen
        self.rootWindow = rootWindow
        self.windowID = windowID
        self.destroyOnDeinit = destroyOnDeinit

        super.init()
    }

    public convenience init(rootWindow: RootWindow, windowID: CXlib.Window, setupSyncCounters: Bool = true) {
        self.init(display: rootWindow.display, screen: rootWindow.screen, rootWindow: rootWindow, windowID: windowID, destroyOnDeinit: true)

        if setupSyncCounters {
            let syncValue = XSyncValue(hi: 0, lo: 0)
            let basicSyncCounter = XSyncCreateCounter(display.handle, syncValue)

            if rootWindow.supportsExtendedSyncCounter == true {
                let extendedSyncCounter = XSyncCreateCounter(display.handle, syncValue)
                syncCounter = (basicSyncCounter, extendedSyncCounter)
                
                set(property: display.syncCounterAtom, type: XA_CARDINAL, format: .thirtyTwo, value: syncCounter)
            } else {
                syncCounter = (basicSyncCounter, XSyncCounter(None))
                
                set(property: display.syncCounterAtom, type: XA_CARDINAL, format: .thirtyTwo, value: syncCounter.basic)
            }
        }
    }

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

    public func get<T>(property: Atom, type: Atom) -> T? {
        var numberOfItems: UInt = 0
        var bytesAfterReturn: UInt = 0
        var itemsBytesPointer: UnsafeMutablePointer<UInt8>? = nil
        var actualType: Atom = Atom(None)
        var actualFormat: CInt = 0

        XGetWindowProperty(display.handle, windowID, property, 0, Int.max, 0, type, &actualType, &actualFormat, &numberOfItems, &bytesAfterReturn, &itemsBytesPointer)

        return itemsBytesPointer.flatMap { itemsBytesPointer in
            let itemsBytesSmartPointer = SmartPointer(with: itemsBytesPointer, deleter: .custom {
                XFree(UnsafeMutableRawPointer($0))
            })

            let itemsPointer = itemsBytesSmartPointer.assumingMemoryBound(to: T.self)

            let items: [T] = Array(UnsafeBufferPointer(start: itemsPointer, count: Int(numberOfItems)))

            assert(items.count == 1, "Expecting only one item of \(T.self) type, but got \(items.count)")

            return items.first
        }
    }

    public func set<T>(property: Atom, type: Atom, format: PropertyType, mode: XlibPropertyChangeMode = .replace, value: T) {
        let size = MemoryLayout.size(ofValue: value)
        
        withUnsafeBytes(of: value) { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            _ = XChangeProperty(display.handle, windowID, property, type, format.bitCount, mode.rawValue, buffer.baseAddress, CInt(size) / format.byteCount)
        }
    }

    public func get<T>(property: Atom, type: Atom) -> [T] {
        var numberOfItems: UInt = 0
        var bytesAfterReturn: UInt = 0
        var itemsBytesPointer: UnsafeMutablePointer<UInt8>? = nil
        var actualType: Atom = Atom(None)
        var actualFormat: CInt = 0

        XGetWindowProperty(display.handle, windowID, property, 0, Int.max, 0, type, &actualType, &actualFormat, &numberOfItems, &bytesAfterReturn, &itemsBytesPointer)

        if let itemsBytesPointer = itemsBytesPointer {
            let itemsBytesSmartPointer = SmartPointer(with: itemsBytesPointer, deleter: .custom {
                XFree(UnsafeMutableRawPointer($0))
            })

            let itemsPointer = itemsBytesSmartPointer.assumingMemoryBound(to: T.self)

            let items: [T] = Array(UnsafeBufferPointer(start: itemsPointer, count: Int(numberOfItems)))

            return items
        } else {
            return []
        }
    }

    public func set<T>(property: Atom, type: Atom, format: PropertyType, mode: XlibPropertyChangeMode = .replace, value: [T]) {
        value.withUnsafeBytes { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            _ = XChangeProperty(display.handle, windowID, property, type, format.bitCount, mode.rawValue, buffer.baseAddress, CInt(value.count))
        }
    }

    public var syncRequested: Bool = false

    internal var syncCounter: (basic: XSyncCounter, extended: XSyncCounter) = (XSyncCounter(None), XSyncCounter(None))

    public var currentSyncCounterValue: XSyncValue = XSyncValue(hi: 0, lo: 0)
    public var incomingSyncCounterValue: XSyncValue? = nil

    public func sendSyncCounterIfNeeded() {
        guard syncRequested else { return }

        let counter: XSyncCounter
        
        if rootWindow?.supportsExtendedSyncCounter == true {
            counter = syncCounter.extended
        } else {
            counter = syncCounter.basic
        }

        if counter == XSyncCounter(None) { return }

        XSyncSetCounter(display.handle, counter, currentSyncCounterValue)

        display.flush()

        syncRequested = false
    }

    public func syncRequested(with value: XSyncValue) {
        currentSyncCounterValue = value
        
        syncRequested = true
    }
}

public extension Rect where StorageType == CInt {
    init(x11WindowAttributes windowAttributes: XWindowAttributes) {
        self.init(x: windowAttributes.x, y: windowAttributes.y, width: windowAttributes.width, height: windowAttributes.height)
    }
}
