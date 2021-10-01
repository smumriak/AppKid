//
//  Event+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import TinyFoundation
import CoreFoundation
import CXlib
import CairoGraphics

fileprivate extension XEvent {
    var eventTypeFromXEvent: Event.EventType {
        switch x11EventType {
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
            return .none
        }
    }
}

fileprivate extension XEvent {
    var keyboardEventType: Event.EventType {
        var mutableCopy = self
        let keySymbol = XLookupKeysym(&mutableCopy.xkey, 0)
        // palkovnik: swift generates intializer that actually allows initialization with invalid value :/
        if let x11ModifierKeySymbol = X11ModifierKeySymbol(rawValue: keySymbol), x11ModifierKeySymbol.isValidRawValue {
            return .flagsChanged
        } else {
            switch x11EventType {
            case .keyPress: return .keyDown
            case .keyRelease: return .keyUp
            default: return .none
            }
        }
    }

    var mouseDownEvent: Event.EventType {
        switch xbutton.buttonName {
        case .one: return .leftMouseDown
        case .two: return .otherMouseDown
        case .three: return .rightMouseDown
        case .four, .five: return .scrollWheel
        default: return .otherMouseDown
        }
    }

    var mouseDraggedEvent: Event.EventType {
        switch xmotion.buttonMask {
        case .one: return .leftMouseDragged
        case .two: return .otherMouseDragged
        case .three: return .rightMouseDragged
        case .four, .five: return .otherMouseDragged
        default: return .mouseMoved
        }
    }

    var mouseUpEvent: Event.EventType {
        switch xbutton.buttonName {
        case .one: return .leftMouseUp
        case .two: return .otherMouseUp
        case .three: return .rightMouseUp
        case .four, .five: return .scrollWheel
        default: return .otherMouseUp
        }
    }
}

fileprivate extension XButtonEvent {
    var modifierFlags: Event.ModifierFlags {
        var result: Event.ModifierFlags = []

        let keyMask = XlibEventKeyMask(rawValue: CInt(state))

        if keyMask.contains(.shift) { result.formUnion(.shift) }
        if keyMask.contains(.lock) { result.formUnion(.capsLock) }
        if keyMask.contains(.control) { result.formUnion(.control) }
        if keyMask.contains(.mod1) { result.formUnion(.option) }
        if keyMask.contains(.mod2) { result.formUnion(.numericPad) }
        if keyMask.contains(.mod4) { result.formUnion(.command) }

        return result
    }
}

internal extension Event {
    convenience init(x11Event: XEvent, timestamp: TimeInterval, displayServer: X11DisplayServer) throws {
        let type = x11Event.eventTypeFromXEvent
        
        if type == .none {
            let eventString = x11Event.x11EventType.map { String(reflecting: $0) } ?? "unknown"
            throw Error.nativeEventIgnored(description: "X11 event type: \(eventString)")
        }

        guard let windowNumber = displayServer.nativeIdentifierToWindowNumber[x11Event.xany.window] else {
            let eventString = x11Event.x11EventType.map { String(reflecting: $0) } ?? "unknown"
            throw Error.noWindow(description: "X11 event type: \(eventString). Foreign window ID: \(x11Event.xany.window)")
        }

        switch type {
        case _ where type.isAnyMouse:
            let buttonEvent = x11Event.xbutton

            let location = CGPoint(x: CGFloat(buttonEvent.x), y: CGFloat(buttonEvent.y)) / displayServer.context.scale
            try self.init(withMouseEventType: type, location: location, modifierFlags: buttonEvent.modifierFlags, timestamp: timestamp, windowNumber: windowNumber, eventNumber: 0, clickCount: 0, pressure: 0.0)

            buttonNumber = Int(buttonEvent.button)
            
        case .appKidDefined:
            switch x11Event.xany.type {
            case MapNotify:
                self.init(withAppKidEventSubType: .windowMapped, windowNumber: windowNumber)

            case UnmapNotify:
                self.init(withAppKidEventSubType: .windowUnmapped, windowNumber: windowNumber)
                
            case Expose:
                self.init(withAppKidEventSubType: .windowExposed, windowNumber: windowNumber)
                
            case ClientMessage:
                let atom = Atom(x11Event.xclient.data.l.0)

                guard atom != Atom(None) else {
                    self.init(withAppKidEventSubType: .message, windowNumber: windowNumber)
                    return
                }

                switch atom {
                case displayServer.display.deleteWindowAtom:
                    self.init(withAppKidEventSubType: .windowDeleteRequest, windowNumber: windowNumber)

                case displayServer.display.syncRequestAtom:
                    self.init(withAppKidEventSubType: .windowSyncRequest, windowNumber: windowNumber)
                    syncCounterValue = XSyncValue(hi: CInt(x11Event.xclient.data.l.3), lo: CUnsignedInt(x11Event.xclient.data.l.2))

                default:
                    self.init(withAppKidEventSubType: .message, windowNumber: windowNumber)
                }

            case ConfigureNotify:
                let configureEvent = x11Event.xconfigure

                self.init(withAppKidEventSubType: .configurationChanged, windowNumber: windowNumber)
                deltaX = CGFloat(configureEvent.width) / displayServer.context.scale
                deltaY = CGFloat(configureEvent.height) / displayServer.context.scale
                
            default:
                self.init(withAppKidEventSubType: .none, windowNumber: windowNumber)
            }
        
        default:
            throw Error.eventIgnored(description: "Event type: \(type)")
        }
    }
}
