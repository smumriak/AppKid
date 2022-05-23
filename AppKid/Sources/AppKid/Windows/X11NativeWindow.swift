//
//  X11WindowInfo.swift
//  AppKid
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation
import CoreFoundation
import TinyFoundation
import SwiftXlib
import CXlib

protocol NativeWindow: AnyObject {
    var title: String { get set }
    var opacity: CGFloat { get set }
}

public final class X11NativeWindow: NSObject, NativeWindow {
    public fileprivate(set) var display: SwiftXlib.Display
    public fileprivate(set) var screen: UnsafeMutablePointer<CXlib.Screen>
    public fileprivate(set) var windowIdentifier: CXlib.Window

    public fileprivate(set) var window: SwiftXlib.Window

    var title: String = "" {
        didSet {
            title.withCString {
                _ = XStoreName(display.handle, windowIdentifier, $0)
            }
        }
    }

    var currentRect: CGRect {
        return currentIntRect.cgRect
    }
    
    var currentIntRect: Rect<CInt> {
        return Rect<CInt>(x11WindowAttributes: window.attributes)
    }

    var isRoot: Bool {
        return screen.pointee.root == windowIdentifier
    }

    var acceptsMouseMovedEvents: Bool = false {
        didSet {
            if !kEnableXInput2 {
                var mask = XlibEventTypeMask.basic
                if acceptsMouseMovedEvents {
                    mask.formUnion(.pointerMotion)
                }

                XSelectInput(display.handle, windowIdentifier, Int(mask.rawValue))
            }
        }
    }
    
    func setFloatsOnTop() {
        var event = XClientMessageEvent()
        event.type = ClientMessage
        event.window = windowIdentifier
        event.message_type = display.knownAtom(.state)
        event.format = 32
        event.data.l.0 = 1
        event.data.l.1 = Int(display.knownAtom(.stateAbove))
        event.data.l.2 = 0
        event.data.l.3 = 0
        event.data.l.4 = 0

        display.rootWindow.send(event: event)

        display.flush()
    }

    public func transitionToFullScreen() {
        var event = XClientMessageEvent()
        event.type = ClientMessage
        event.window = windowIdentifier
        event.message_type = display.knownAtom(.state)
        event.format = 32
        event.data.l.0 = 1
        event.data.l.1 = Int(display.knownAtom(.stateFullscreen))
        event.data.l.2 = 0
        event.data.l.3 = 0
        event.data.l.4 = 0

        display.rootWindow.send(event: event)

        display.flush()
    }

    public var displayScale: CGFloat = 1.0

    internal var opacity: CGFloat = 1.0 {
        didSet {
            let value = UInt32(opacity * CGFloat(UInt32.max))
            withUnsafePointer(to: value) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: opacity)) {
                    let optional: UnsafePointer<UInt8>? = $0
                    XChangeProperty(display.handle, windowIdentifier, display.knownAtom(.opacity), XA_CARDINAL, 32, PropModeReplace, optional, 1)
                }
            }
        }
    }

    public var syncRequested: Bool = false

    var inputContext: XIC? = nil
        
    internal init(display: SwiftXlib.Display, screen: UnsafeMutablePointer<CXlib.Screen>, windowIdentifier: CXlib.Window, title: String) {
        self.display = display
        self.screen = screen
        self.windowIdentifier = windowIdentifier
        self.title = title
        
        self.window = SwiftXlib.Window(rootWindow: display.rootWindow, windowIdentifier: windowIdentifier)

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

            XISelectEvents(display.handle, windowIdentifier, &eventMasks, CInt(eventMasks.count))
            XSelectInput(display.handle, windowIdentifier, Int(XlibEventTypeMask.geometry.rawValue))
        } else {
            XSelectInput(display.handle, windowIdentifier, Int(XlibEventTypeMask.basic.rawValue))
        }
    }

    func map(displayServer: X11DisplayServer) {
        XMapWindow(display.handle, windowIdentifier)
    }
}

public extension X11NativeWindow {
    static func == (lhs: X11NativeWindow, rhs: X11NativeWindow) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs) || lhs.windowIdentifier == rhs.windowIdentifier
    }
}
