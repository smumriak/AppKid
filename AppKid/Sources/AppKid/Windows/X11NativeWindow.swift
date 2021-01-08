//
//  X11WindowInfo.swift
//  AppKid
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import TinyFoundation
import Foundation

import SwiftXlib
import CXlib

protocol NativeWindow: class {
    var title: String { get set }
    var opacity: CGFloat { get set }
}

public final class X11NativeWindow: NSObject, NativeWindow {
    public fileprivate(set) var display: SwiftXlib.Display
    public fileprivate(set) var screen: UnsafeMutablePointer<CXlib.Screen>
    public fileprivate(set) var windowID: CXlib.Window

    var title: String = "" {
        didSet {
            title.withCString {
                _ = XStoreName(display.handle, windowID, $0)
            }
        }
    }
    
    var attributes: XWindowAttributes {
        var windowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display.handle, windowID, &windowAttributes) == 0 {
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
                var mask = XlibEventTypeMask.basic
                if acceptsMouseMovedEvents {
                    mask.formUnion(.pointerMotion)
                }

                XSelectInput(display.handle, windowID, Int(mask.rawValue))
            }
        }
    }
    
    // TODO: palkovnik: Looks like native window will need access to display context after all. Looks like Screen class is coming
    // func setFloatsOnTop() {
    //     var event = XClientMessageEvent()
    //     event.type = ClientMessage
    //     event.window = Application.shared.windows[0].nativeWindow.windowID
    //     event.message_type = context.stateAtom
    //     event.format = 32
    //     event.data.l.0 = 1
    //     event.data.l.1 = Int(context.stayAboveAtom)
    //     event.data.l.2 = 0
    //     event.data.l.3 = 0
    //     event.data.l.4 = 0

    //     let size = MemoryLayout.size(ofValue: event)

    //     withUnsafeMutablePointer(to: &event) { event in
    //         event.withMemoryRebound(to: XEvent.self, capacity: size) { event in
    //             let _ = XSendEvent(display, XDefaultRootWindow(display), 0, SubstructureRedirectMask | SubstructureNotifyMask, event)
    //         }
    //     }
    // }

    public func transitionToFullScreen() {
        var event = XClientMessageEvent()
        event.type = ClientMessage
        event.window = windowID
        event.message_type = display.stateAtom
        event.format = 32
        event.data.l.0 = 1
        event.data.l.1 = Int(display.stateFullscreenAtom)
        event.data.l.2 = 0
        event.data.l.3 = 0
        event.data.l.4 = 0

        let size = MemoryLayout.size(ofValue: event)

        withUnsafeMutablePointer(to: &event) { event in
            event.withMemoryRebound(to: XEvent.self, capacity: size) { event in
                let _ = XSendEvent(display.handle, XDefaultRootWindow(display.handle), 0, SubstructureRedirectMask | SubstructureNotifyMask, event)
            }
        }

        display.flush()
    }

    public var displayScale: CGFloat = 1.0

    internal var opacity: CGFloat = 1.0 {
        didSet {
            let value = UInt32(opacity * CGFloat(UInt32.max))
            withUnsafePointer(to: value) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: opacity)) {
                    let optional: UnsafePointer<UInt8>? = $0
                    XChangeProperty(display.handle, windowID, display.opacityAtom, XA_CARDINAL, 32, PropModeReplace, optional, 1)
                }
            }
        }
    }

    public var syncFence: XSyncFence = XSyncFence(None)

    internal var syncCounter: (basic: XSyncCounter, extended: XSyncCounter) = (XSyncCounter(None), XSyncCounter(None)) {
        didSet {
            let size = MemoryLayout.size(ofValue: syncCounter)
            withUnsafePointer(to: &syncCounter) {
                $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                    let optional: UnsafePointer<UInt8>? = $0
                    XChangeProperty(display.handle, windowID, display.syncCounterAtom, XA_CARDINAL, 32, PropModeReplace, optional, 2)
                }
            }
        }
    }

    public internal(set) var basicSyncCounter: Int64 = 0
    public func sendBasicSyncCounterValue() {
        guard syncCounter.basic != Atom(None) else { return }

        let value = XSyncValue(hi: Int32(basicSyncCounter >> 32), lo: UInt32(basicSyncCounter & 0xFFFFFFFF))
        XSyncSetCounter(display.handle, syncCounter.basic, value)
    }

    public internal(set) var extendedSyncCounter: Int64 = 0
    public func sendExtendedSyncCounterValue() {
        guard syncCounter.extended != Atom(None) else { return }

        let value = XSyncValue(hi: Int32(extendedSyncCounter >> 32), lo: UInt32(extendedSyncCounter & 0xFFFFFFFF))
        XSyncSetCounter(display.handle, syncCounter.extended, value)
    }

    public var syncRequested: Bool = false
    public var rendererResized: Bool = false

    var inputContext: XIC? = nil
    
    deinit {
        if syncCounter.basic != XSyncCounter(None) {
            XSyncDestroyCounter(display.handle, syncCounter.basic)
        }

        if syncCounter.extended != XSyncCounter(None) {
            XSyncDestroyCounter(display.handle, syncCounter.extended)
        }

        if !isRoot {
            XDestroyWindow(display.handle, windowID)
        }

        if syncFence != XSyncFence(None) {
            XSyncDestroyFence(display.handle, syncFence)
        }
    }
    
    internal init(display: SwiftXlib.Display, screen: UnsafeMutablePointer<CXlib.Screen>, windowID: CXlib.Window, title: String) {
        self.display = display
        self.screen = screen
        self.windowID = windowID
        self.title = title

        super.init()
    }

    func updateListeningEvents(displayServer: X11DisplayServer) {
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

            XISelectEvents(display.handle, windowID, &eventMasks, CInt(eventMasks.count))
            XSelectInput(display.handle, windowID, Int(XlibEventTypeMask.geometry.rawValue))
        } else {
            XSelectInput(display.handle, windowID, Int(XlibEventTypeMask.basic.rawValue))
        }
    }

    func map(displayServer: X11DisplayServer) {
        XMapWindow(display.handle, windowID)
    }
}

extension X11NativeWindow {
    public static func == (lhs: X11NativeWindow, rhs: X11NativeWindow) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs) || lhs.windowID == rhs.windowID
    }
}
