//
//  Window.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation
import TinyFoundation
import CXlib

public class Window: NSObject, WindowProtocol {
    public let display: Display
    public let screen: Screen
    public let rootWindow: RootWindow?
    public let windowIdentifier: CXlib.Window
    public let destroyOnDeinit: Bool
    
    deinit {
        sendUnmapRequest()

        if syncCounter.basic != XSyncCounter(None) {
            XSyncDestroyCounter(display.handle, syncCounter.basic)
        }

        if syncCounter.extended != XSyncCounter(None) {
            XSyncDestroyCounter(display.handle, syncCounter.extended)
        }
        
        if destroyOnDeinit {
            XDestroyWindow(display.handle, windowIdentifier)
        }
    }

    internal init(display: Display, screen: Screen, rootWindow: RootWindow?, windowIdentifier: CXlib.Window, destroyOnDeinit: Bool) {
        self.display = display
        self.screen = screen
        self.rootWindow = rootWindow
        self.windowIdentifier = windowIdentifier
        self.destroyOnDeinit = destroyOnDeinit

        super.init()
    }

    public convenience init(rootWindow: RootWindow, windowIdentifier: CXlib.Window, setupSyncCounters: Bool = true) {
        self.init(display: rootWindow.display, screen: rootWindow.screen, rootWindow: rootWindow, windowIdentifier: windowIdentifier, destroyOnDeinit: true)

        if display.rootWindow.windowIdentifier == windowIdentifier {
            return
        }

        if setupSyncCounters {
            let syncValue = XSyncValue(hi: 0, lo: 0)
            let basicSyncCounter = XSyncCreateCounter(display.handle, syncValue)

            if rootWindow.supportsExtendedSyncCounter == true {
                let extendedSyncCounter = XSyncCreateCounter(display.handle, syncValue)
                syncCounter = (basicSyncCounter, extendedSyncCounter)
                set(property: display.knownAtom(.syncCounter), type: XA_CARDINAL, format: .thirtyTwo, value: syncCounter)
            } else {
                syncCounter = (basicSyncCounter, XSyncCounter(None))
                
                set(property: display.knownAtom(.syncCounter), type: XA_CARDINAL, format: .thirtyTwo, value: syncCounter.basic)
            }
        }
    }
    
    internal var syncCounter: (basic: XSyncCounter, extended: XSyncCounter) = (XSyncCounter(None), XSyncCounter(None))

    public internal(set) var currentSyncCounterValue: XSyncValue = XSyncValue(hi: 0, lo: 0)
    public internal(set) var incomingSyncCounterValue: XSyncValue? = nil

    public func sendSyncCounterForRenderingStart() {
        guard rootWindow?.supportsExtendedSyncCounter == true else {
            return
        }

        guard incomingSyncCounterValue == nil else {
            return
        }

        let counter = syncCounter.extended
        var newValue = XSyncValue(hi: 0, lo: 0)
        var overflow: CInt = 0
        
        if XSyncValueLow32(currentSyncCounterValue) % 2 == 0 {
            XSyncValueAdd(&newValue, currentSyncCounterValue, XSyncValue(hi: 0, lo: 3), &overflow)
        } else {
            XSyncValueAdd(&newValue, currentSyncCounterValue, XSyncValue(hi: 0, lo: 3), &overflow)
        }

        XSyncSetCounter(display.handle, counter, newValue)
        currentSyncCounterValue = newValue

        display.flush()

        overflow = 0
        XSyncValueAdd(&newValue, newValue, XSyncValue(hi: 0, lo: 1), &overflow)

        incomingSyncCounterValue = newValue
    }

    public func sendSyncCounterIfNeeded() {
        guard let newValue = incomingSyncCounterValue else {
            return
        }

        let counter: XSyncCounter
        
        if rootWindow?.supportsExtendedSyncCounter == true {
            counter = syncCounter.extended
        } else {
            counter = syncCounter.basic
        }

        if counter == XSyncCounter(None) { return }

        XSyncSetCounter(display.handle, counter, newValue)
        currentSyncCounterValue = newValue

        display.flush()

        incomingSyncCounterValue = nil
    }

    public func syncRequested(with value: XSyncValue) {
        incomingSyncCounterValue = value
    }

    public func sendMapRequest() {
        XMapWindow(display.handle, windowIdentifier)
    }

    public func sendUnmapRequest() {
        XUnmapWindow(display.handle, windowIdentifier)
    }

}

public extension Rect where StorageType == CInt {
    init(x11WindowAttributes windowAttributes: XWindowAttributes) {
        self.init(x: windowAttributes.x, y: windowAttributes.y, width: windowAttributes.width, height: windowAttributes.height)
    }
}

public enum PropertyFormat {
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

public protocol WindowProtocol {
    var display: Display { get }
    var screen: Screen { get }
    var rootWindow: RootWindow? { get }
    var windowIdentifier: CXlib.Window { get }
    var destroyOnDeinit: Bool { get }
}

public extension WindowProtocol {
    func get<T>(property: Atom, type: CXlib.Atom) -> T? {
        var numberOfItems: UInt = 0
        var bytesAfterReturn: UInt = 0
        var itemsBytesPointer: UnsafeMutablePointer<UInt8>? = nil
        var actualType: CXlib.Atom = CXlib.Atom(None)
        var actualFormat: CInt = 0

        XGetWindowProperty(display.handle, windowIdentifier, property, 0, Int.max, 0, type, &actualType, &actualFormat, &numberOfItems, &bytesAfterReturn, &itemsBytesPointer)

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

    func set<T>(property: Atom, type: CXlib.Atom, format: PropertyFormat, mode: XlibPropertyChangeMode = .replace, value: T) {
        let stride = MemoryLayout<T>.stride
        
        withUnsafeBytes(of: value) { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            _ = XChangeProperty(display.handle, windowIdentifier, property, type, format.bitCount, mode.rawValue, buffer.baseAddress, CInt(stride) / format.byteCount)
        }
    }

    func get<T>(property: Atom, type: CXlib.Atom) -> [T] {
        var numberOfItems: UInt = 0
        var bytesAfterReturn: UInt = 0
        var itemsBytesPointer: UnsafeMutablePointer<UInt8>? = nil
        var actualType: CXlib.Atom = CXlib.Atom(None)
        var actualFormat: CInt = 0

        XGetWindowProperty(display.handle, windowIdentifier, property, 0, Int.max, 0, type, &actualType, &actualFormat, &numberOfItems, &bytesAfterReturn, &itemsBytesPointer)

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

    func set<T>(property: Atom, type: CXlib.Atom, format: PropertyFormat, mode: XlibPropertyChangeMode = .replace, value: [T]) {
        value.withUnsafeBytes { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            _ = XChangeProperty(display.handle, windowIdentifier, property, type, format.bitCount, mode.rawValue, buffer.baseAddress, CInt(value.count))
        }
    }
}

public extension WindowProtocol {
    var attributes: XWindowAttributes {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display.handle, windowIdentifier, &windowAttributes) == 0 {
            fatalError("Can not get window attributes for window with ID: \(windowIdentifier)")
        }
        return windowAttributes
    }

    func send<T: XEventProtocol>(event: T) {
        var eventCopy = event
        eventCopy.withTypeErasedEvent { event in
            _ = XSendEvent(display.handle, XDefaultRootWindow(display.handle), 0, SubstructureRedirectMask | SubstructureNotifyMask, event)
        }
    }
}
