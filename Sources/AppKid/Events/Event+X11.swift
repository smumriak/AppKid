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

fileprivate extension XEvent {
    var eventTypeFromXEvent: Event.EventType {
        guard let type = X11EventType(rawValue: type) else {
            return .noEvent
        }

        switch type {
        case .keyPress, .keyRelease:
            return keyboardEventType

        case .buttonPress:
            return mouseDownEvent

        case .buttonRelease:
            return mouseUpEvent

        case .motionNotify:
            return mouseDraggedEvent

        case .enterNotify:
            return .mouseEntered

        case .leaveNotify:
            return .mouseExited

        case .expose, .graphicsExpose, .noExpose, .mapNotify, .reparentNotify, .configureNotify, .clientMessage:
            return .appKidDefined

        case .mappingNotify:
            return .systemDefined

        default:
            return .noEvent
        }
    }
}

fileprivate extension XEvent {
    var keyboardEventType: Event.EventType {
        var mutableCopy = self
        let keySymbol = XLookupKeysym(&mutableCopy.xkey, 0)
        if Event.ModifierFlags.x11ModifierKeySymbols.contains(keySymbol) {
            return .flagsChanged
        } else {
            switch X11EventType(rawValue: type) {
            case .keyPress: return .keyDown
            case .keyRelease: return .keyUp
            default: return .noEvent
            }
        }
    }

    var mouseDownEvent: Event.EventType {
        guard let buttonName = X11EventButtonName(rawValue: CInt(xbutton.button)) else {
            return .otherMouseDown
        }

        switch buttonName {
        case .one: return .leftMouseDown
        case .two: return .otherMouseDown
        case .three: return .rightMouseDown
        case .four, .five: return .scrollWheel
        }
    }

    var mouseDraggedEvent: Event.EventType {
        let buttonMask = X11EventButtonMask(rawValue: CInt(xmotion.state))

        switch buttonMask {
        case .one: return .leftMouseDragged
        case .two: return .otherMouseDragged
        case .three: return .rightMouseDragged
        case .four, .five: return .otherMouseDragged
        default: return .mouseMoved
        }
    }

    var mouseUpEvent: Event.EventType {
        guard let buttonName = X11EventButtonName(rawValue: CInt(xbutton.button)) else {
            return .otherMouseUp
        }

        switch buttonName {
        case .one: return .leftMouseUp
        case .two: return .otherMouseUp
        case .three: return .rightMouseUp
        case .four, .five: return .scrollWheel
        }
    }
}

fileprivate extension XButtonEvent {
    var modifierFlags: Event.ModifierFlags {
        var result: Event.ModifierFlags = []

        let keyMask = X11EventKeyMask(rawValue: CInt(state))

        if keyMask.contains(.shift) { result.formUnion(.shift) }
        if keyMask.contains(.lock) { result.formUnion(.capsLock) }
        if keyMask.contains(.control) { result.formUnion(.control) }
        if keyMask.contains(.mod1) { result.formUnion(.option) }
        if keyMask.contains(.mod2) { result.formUnion(.numericPad) }
        if keyMask.contains(.mod4) { result.formUnion(.command) }

        return result
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
}

internal extension Event {
    convenience init(x11Event: XEvent, timestamp: TimeInterval, displayScale: CGFloat) throws {
        let type = x11Event.eventTypeFromXEvent

        guard let windowNumber = Application.shared.windows.firstIndex(where: { $0.nativeWindow.windowID == x11Event.xany.window }) else {
            throw EventCreationError.noWindow
        }
        
        switch type {
        case _ where EventType.mouseEventTypes.contains(type):
            let buttonEvent = x11Event.xbutton

            let location = CGPoint(x: CGFloat(buttonEvent.x) / displayScale, y: CGFloat(buttonEvent.y) / displayScale)
            try self.init(withMouseEventType: type, location: location, modifierFlags: buttonEvent.modifierFlags, timestamp: timestamp, windowNumber: windowNumber, eventNumber: 0, clickCount: 0, pressure: 0.0)

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
