//
//  X11WindowInfo.swift
//  AppKid
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

import CX11.Xlib
import CX11.X
import CXInput2

public final class X11NativeWindow {
    public fileprivate(set) var display: UnsafeMutablePointer<CX11.Display>
    public fileprivate(set) var screen: UnsafeMutablePointer<CX11.Screen>
    public fileprivate(set) var windowID: CX11.Window

    var title: String = "" {
        didSet {
            title.withCString {
                _ = XStoreName(display, windowID, $0)
            }
        }
    }
    
    var attributes: XWindowAttributes {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display, windowID, &windowAttributes) == 0 {
//            fatalError("Can not get window attributes for window with ID: \(windowID)")
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
            }
        }
    }

    public var displayScale: CGFloat = 1.0

    internal lazy var opacityAtom = XInternAtom(display, "_NET_WM_WINDOW_OPACITY", 0)
    internal var opacity: CGFloat = 1.0 {
        didSet {
            let value = UInt32(opacity * CGFloat(UInt32.max))
            withUnsafePointer(to: value) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: opacity)) {
                    let optional: UnsafePointer<UInt8>? = $0
                    XChangeProperty(display, windowID, opacityAtom, XA_CARDINAL, 32, PropModeReplace, optional, 1)
                }
            }
        }
    }

    internal lazy var syncCounterAtom = XInternAtom(display, "_NET_WM_SYNC_REQUEST_COUNTER", 0)

    internal var syncCounter: (basic: XSyncCounter, extended: XSyncCounter) = (XSyncCounter(None), XSyncCounter(None)) {
        didSet {
            let size = MemoryLayout.size(ofValue: syncCounter)
            withUnsafePointer(to: &syncCounter) {
                $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                    let optional: UnsafePointer<UInt8>? = $0
                    XChangeProperty(display, windowID, syncCounterAtom, XA_CARDINAL, 32, PropModeReplace, optional, 2)
                }
            }
        }
    }

    public internal(set) var basicSyncCounter: Int64 = 0
    public func sendBasicSyncCounterValue() {
        guard syncCounter.basic != Atom(None) else { return }

        let value = XSyncValue(hi: Int32(basicSyncCounter >> 32), lo: UInt32(basicSyncCounter & 0xFFFFFFFF))
        XSyncSetCounter(display, syncCounter.basic, value)
    }

    public internal(set) var extendedSyncCounter: Int64 = 0
    public func sendExtendedSyncCounterValue() {
        guard syncCounter.extended != Atom(None) else { return }

        let value = XSyncValue(hi: Int32(extendedSyncCounter >> 32), lo: UInt32(extendedSyncCounter & 0xFFFFFFFF))
        XSyncSetCounter(display, syncCounter.extended, value)
    }

    public var syncRequested: Bool = false
    public var rendererResized: Bool = false

    var inputContext: XIC? = nil
    
    deinit {
        if syncCounter.basic != Atom(None) {
            XSyncDestroyCounter(display, syncCounter.basic)
        }

        if syncCounter.extended != Atom(None) {
            XSyncDestroyCounter(display, syncCounter.extended)
        }

        if !isRoot {
            XDestroyWindow(display, windowID)
        }
    }
    
    internal init(display: UnsafeMutablePointer<CX11.Display>, screen: UnsafeMutablePointer<CX11.Screen>, windowID: CX11.Window, title: String) {
        self.display = display
        self.screen = screen
        self.windowID = windowID
        self.title = title
    }

    func updateListeningEvents(displayServer: DisplayServer) {
        if kEnableXInput2 {
            // what you see below is very unsafe code in swift, but it's more or less usual implicit cast for C code. XInput2 is poorly designed C API with a lot of inconsistent or plain dumb solutions. so what's happening? the code creates XIEventMask structs which require stupid buffer or UInt8 as an input that provides "mask" for the event type. In our case even type mask has to be more than 8 bits. 32 to be precise. so we literallly cast 32 bit uint pointer value to 8 bit uint pointer. hope this does not break in future releases of swift (ha-ha, it will). after "selecting" the needed events by mask the code deallocates the data for those mask buffers
            var eventMasks: [XIEventMask] = displayServer.context.inputDevices
                .map { device in
                    let maskPointer = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
                    maskPointer.initialize(to: UInt32(device.type.mask.rawValue))
                    let reboundMaskPointer = UnsafeMutableRawPointer(maskPointer).bindMemory(to: UInt8.self, capacity: 4)

                    return XIEventMask(deviceid: device.identifier, mask_len: 4, mask: reboundMaskPointer)
            }
            defer {
                eventMasks.forEach {
                    $0.mask.deallocate()
                }
            }

            XISelectEvents(displayServer.display, windowID, &eventMasks, CInt(eventMasks.count))
            XSelectInput(displayServer.display, windowID, Int(X11EventTypeMask.geometry.rawValue))
        } else {
            XSelectInput(displayServer.display, windowID, Int(X11EventTypeMask.basic.rawValue))
        }
    }

    func map(displayServer: DisplayServer) {
        XMapWindow(displayServer.display, windowID)
    }
}

extension X11NativeWindow: Equatable {
    public static func == (lhs: X11NativeWindow, rhs: X11NativeWindow) -> Bool {
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
