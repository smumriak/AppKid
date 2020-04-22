//
//  Event+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import CoreFoundation
import CX11.X
import CX11.Xlib
import CXInput2

extension X11EventTypeMask {
    static let keyboard: X11EventTypeMask = [.keyPress, .keyRelease]
    static let mouse: X11EventTypeMask = [.buttonPress, .buttonRelease]
    static let enterLeave: X11EventTypeMask = [.enterWindow, .leaveWindow]
    static let geometry: X11EventTypeMask = [.exposure, .visibilityChange, .structureNotify]

    static let basic: X11EventTypeMask = [.keyboard, .mouse, .buttonMotion, .enterLeave, .focusChange, .geometry]
}

internal extension Event.EventType {
    init?(x11Event: XEvent) {
        var event = x11Event
        guard let type = X11EventType(rawValue: event.type) else {
            self = .noEvent
            return
        }

        switch type {
        case .keyPress, .keyRelease:
            self = Self.keyboardEventType(for: &event, type: type)

        case .buttonPress:
            self = Self.mouseDownEvent(for: CInt(event.xbutton.button))

        case .buttonRelease:
            self = Self.mouseUpEvent(for: CInt(event.xbutton.button))

        case .motionNotify:
            self = Self.mouseDraggedEvent(for: CInt(event.xmotion.state))

        case .enterNotify:
            self = .mouseEntered

        case .leaveNotify:
            self = .mouseExited

        case .expose, .graphicsExpose, .noExpose, .mapNotify, .reparentNotify, .configureNotify, .clientMessage:
            self = .appKidDefined

        case .mappingNotify:
            self = .systemDefined
            
        default: self = .noEvent
        }
    }
}

fileprivate extension Event.EventType {
    static func keyboardEventType(for event: inout XEvent, type: X11EventType) -> Self {
        let keySymbol = XLookupKeysym(&event.xkey, 0)
        if Event.ModifierFlags.x11ModifierKeySymbols.contains(keySymbol) {
            return .flagsChanged
        } else {
            switch type {
            case .keyPress: return .keyDown
            case .keyRelease: return .keyUp
            default: return .noEvent
            }
        }
    }

    static func mouseUpEvent(for buttonNumber: CInt) -> Self {
        switch buttonNumber {
        case Button1: return .leftMouseUp
        case Button2: return .otherMouseUp
        case Button3: return .rightMouseUp
        case Button4, Button5: return .scrollWheel
        default: return .otherMouseUp
        }
    }

    static func mouseDownEvent(for buttonNumber: CInt) -> Self {
        switch buttonNumber {
        case Button1: return .leftMouseDown
        case Button2: return .otherMouseDown
        case Button3: return .rightMouseDown
        case Button4, Button5: return .scrollWheel
        default: return .otherMouseDown
        }
    }

    static func mouseDraggedEvent(for state: CInt) -> Self {
        switch state {
        case _ where state & Button1Mask != 0: return .leftMouseDragged
        case _ where state & Button2Mask != 0: return .otherMouseDragged
        case _ where state & Button3Mask != 0: return .rightMouseDragged
        case _ where state & Button4Mask != 0: return .otherMouseDragged
        case _ where state & Button5Mask != 0: return .otherMouseDragged
        default: return .mouseMoved
        }
    }
}

internal extension Event.ModifierFlags {
    static let x11ModifierKeySymbols: Set<KeySym> = Set([
        XK_Shift_L, XK_Shift_R,
        XK_Control_L, XK_Control_R,
        XK_Meta_L, XK_Meta_R,
        XK_Alt_L, XK_Alt_R,
        XK_Super_L, XK_Super_R,
        XK_Hyper_L, XK_Hyper_R
        ]
        .map { KeySym($0) })

    init(x11KeyMask: CUnsignedInt) {
        self.init(rawValue: 0)
        let keyMask = CInt(x11KeyMask)

        if keyMask & ShiftMask != 0 { formUnion(.shift) }
        if keyMask & LockMask != 0 { formUnion(.capsLock) }
        if keyMask & ControlMask != 0 { formUnion(.control) }
        if keyMask & Mod1Mask != 0 { formUnion(.option) }
        if keyMask & Mod2Mask != 0 { formUnion(.numericPad) }
        if keyMask & Mod4Mask != 0 { formUnion(.command) }
    }
}

internal extension Event {
    convenience init(x11Event: XEvent, timestamp: TimeInterval, displayScale: CGFloat) throws {
        guard let type = EventType(x11Event: x11Event) else {
            throw EventCreationError.unknownEventType
        }

        guard let windowNumber = Application.shared.windows.firstIndex(where: { $0.nativeWindow.windowID == x11Event.xany.window }) else {
            throw EventCreationError.noWindow
        }
        
        switch type {
        case _ where EventType.mouseEventTypes.contains(type):
            let buttonEvent = x11Event.xbutton

            let location = CGPoint(x: CGFloat(buttonEvent.x) / displayScale, y: CGFloat(buttonEvent.y) / displayScale)
            try self.init(withMouseEventType: type, location: location, modifierFlags: ModifierFlags(x11KeyMask: buttonEvent.state), timestamp: timestamp, windowNumber: windowNumber, eventNumber: 0, clickCount: 0, pressure: 0.0)

            buttonNumber = Int(buttonEvent.button)
            
        case .appKidDefined:
            switch x11Event.xany.type {
            case MapNotify:
                self.init(withAppKidEventSubType: .windowMapped, windowNumber: windowNumber)

            case Expose:
                self.init(withAppKidEventSubType: .windowExposed, windowNumber: windowNumber)
                
            case ClientMessage:
                self.init(withAppKidEventSubType: .message, windowNumber: windowNumber)
                
            case ConfigureNotify:
                self.init(withAppKidEventSubType: .windowResized, windowNumber: windowNumber)
                
            default:
                self.init(withAppKidEventSubType: .windowExposed, windowNumber: windowNumber)
            }
        
        default:
            throw EventCreationError.unparsableEvent
        }
    }
}
