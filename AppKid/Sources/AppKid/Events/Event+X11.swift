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

internal extension XEvent {
    var appKidEventType: Event.EventType {
        switch eventType {
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
        // smumriak: swift generates intializer that actually allows initialization with invalid value :/
        if let x11ModifierKeySymbol = X11ModifierKeySymbol(rawValue: keySymbol), x11ModifierKeySymbol.isValidRawValue {
            return .flagsChanged
        } else {
            switch eventType {
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

internal extension XButtonEvent {
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
    @_transparent
    convenience init(x11Event: XEvent, timestamp: TimeInterval, displayServer: X11DisplayServer) throws {
        let type = x11Event.appKidEventType
        
        if type == .none {
            let eventString = x11Event.eventType.map { String(reflecting: $0) } ?? "unknown"
            throw Error.nativeEventIgnored(description: "X11 event type: \(eventString)")
        }

        guard let windowNumber = displayServer.nativeIdentifierToWindowNumber[x11Event.xany.window] else {
            let eventString = x11Event.eventType.map { String(reflecting: $0) } ?? "unknown"
            throw Error.noWindow(description: "X11 event type: \(eventString). Foreign window ID: \(x11Event.xany.window)")
        }

        switch type {
            case .appKidDefined:
                switch x11Event.eventType {
                    case .mapNotify:
                        self.init(withAppKidEventSubType: .windowMapped, windowNumber: windowNumber)

                    case .unmapNotify:
                        self.init(withAppKidEventSubType: .windowUnmapped, windowNumber: windowNumber)
                
                    case .expose:
                        self.init(withAppKidEventSubType: .windowExposed, windowNumber: windowNumber)
                
                    case .clientMessage:
                        self.init(clientMessageEvent: x11Event.xclient, timestamp: timestamp, displayServer: displayServer, windowNumber: windowNumber)

                    case .configureNotify:
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

    @_transparent
    convenience init(clientMessageEvent: XClientMessageEvent, timestamp: TimeInterval, displayServer: X11DisplayServer, windowNumber: Int) {
        switch clientMessageEvent.message_type {
            case displayServer.display.knownAtom(.protocols):
                let atom = Atom(clientMessageEvent.data.l.0)

                guard atom != Atom(None) else {
                    self.init(withAppKidEventSubType: .message, windowNumber: windowNumber)
                    return
                }

                switch atom {
                    case displayServer.display.knownAtom(.deleteWindow):
                        self.init(withAppKidEventSubType: .windowDeleteRequest, windowNumber: windowNumber)

                    case displayServer.display.knownAtom(.syncRequest):
                        self.init(withAppKidEventSubType: .windowSyncRequest, windowNumber: windowNumber)
                        syncCounterValue = XSyncValue(hi: CInt(clientMessageEvent.data.l.3), lo: CUnsignedInt(clientMessageEvent.data.l.2))

                    case displayServer.display.knownAtom(.frameDrawn):
                        self.init(withAppKidEventSubType: .message, windowNumber: windowNumber)

                    default:
                        self.init(withAppKidEventSubType: .message, windowNumber: windowNumber)
                }

            default:
                self.init(withAppKidEventSubType: .message, windowNumber: windowNumber)
        }
    }
}
