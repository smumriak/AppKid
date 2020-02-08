//
//  Event+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation
import CoreFoundation
import CX11.X
import CX11.Xlib

internal extension Event.EventType {
    static func x11EventMask() -> Int {
        return [
            KeyPressMask,
            KeyReleaseMask,
            ButtonPressMask,
            ButtonReleaseMask,
            EnterWindowMask,
            LeaveWindowMask,
            PointerMotionMask,
//            PointerMotionHintMask,
//            Button1MotionMask,
//            Button2MotionMask,
//            Button3MotionMask,
//            Button4MotionMask,
//            Button5MotionMask,
//            ButtonMotionMask,
//            KeymapStateMask,
            ExposureMask,
            VisibilityChangeMask,
            StructureNotifyMask,
//            ResizeRedirectMask,
//            SubstructureNotifyMask,
//            SubstructureRedirectMask,
            FocusChangeMask,
//            PropertyChangeMask,
//            ColormapChangeMask,
//            OwnerGrabButtonMask,
            ]
            .reduce(NoEventMask, |)
    }
    
    init?(x11Event: CX11.XEvent) {
        var x11Event = x11Event
        switch x11Event.type {
        case KeyPress:
            let keySymbol = XLookupKeysym(&x11Event.xkey, 0)
            if Event.ModifierFlags.x11ModifierKeySymbols.contains(keySymbol) {
                self = .flagsChanged
            } else {
                self = .keyDown
            }
        case KeyRelease:
            let keySymbol = XLookupKeysym(&x11Event.xkey, 0)
            if Event.ModifierFlags.x11ModifierKeySymbols.contains(keySymbol) {
                self = .flagsChanged
            } else {
                self = .keyUp
            }
        case ButtonPress:
            switch Int32(x11Event.xbutton.button) {
            case Button1:
                self = .leftMouseDown
            case Button2:
                self = .otherMouseDown
            case Button3:
                self = .rightMouseDown
            case Button4, Button5:
                self = .scrollWheel
            default:
                self = .otherMouseDown
            }
            
        case ButtonRelease:
            switch Int32(x11Event.xbutton.button) {
            case Button1:
                self = .leftMouseUp
            case Button2:
                self = .otherMouseUp
            case Button3:
                self = .rightMouseUp
            case Button4, Button5:
                self = .scrollWheel
            default:
                self = .otherMouseUp
            }
            
        case MotionNotify:
            let state = Int32(x11Event.xmotion.state)
            
            switch state {
            case _ where state & Button1Mask != 0:
                self = .leftMouseDragged
            case _ where state & Button2Mask != 0:
                self = .otherMouseDragged
            case _ where state & Button3Mask != 0:
                self = .rightMouseDragged
            case _ where state & Button4Mask != 0:
                self = .otherMouseDragged
            case _ where state & Button5Mask != 0:
                self = .otherMouseDragged
            default:
                self = .mouseMoved
            }
        case EnterNotify:
            self = .mouseEntered
        case LeaveNotify:
            self = .mouseExited
        case FocusIn:
            self = .noEvent
        case FocusOut:
            self = .noEvent
        case KeymapNotify:
            self = .noEvent
        case Expose:
            self = .appKidDefined
        case GraphicsExpose:
            self = .appKidDefined
        case NoExpose:
            self = .appKidDefined
        case VisibilityNotify:
            self = .noEvent
        case CreateNotify:
            self = .noEvent
        case DestroyNotify:
            self = .noEvent
        case UnmapNotify:
            self = .noEvent
        case MapNotify:
            self = .noEvent
        case MapRequest:
            self = .noEvent
        case ReparentNotify:
            self = .appKidDefined
        case ConfigureNotify:
            self = .noEvent
        case ConfigureRequest:
            self = .noEvent
        case GravityNotify:
            self = .noEvent
        case ResizeRequest:
            self = .noEvent
        case CirculateNotify:
            self = .noEvent
        case CirculateRequest:
            self = .noEvent
        case PropertyNotify:
            self = .noEvent
        case SelectionClear:
            self = .noEvent
        case SelectionRequest:
            self = .noEvent
        case SelectionNotify:
            self = .noEvent
        case ColormapNotify:
            self = .noEvent
        case ClientMessage:
            self = .appKidDefined
        case MappingNotify:
            self = .systemDefined
        case GenericEvent:
            self = .noEvent
        case LASTEvent:
            self = .noEvent
            
        default:
            return nil
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
    
    init(x11KeyMask: UInt32) {
        self.init(rawValue: 0)
        let keyMask = Int32(x11KeyMask)
        
        if keyMask & ShiftMask != 0 { formUnion(.shift) }
        if keyMask & LockMask != 0 { formUnion(.capsLock) }
        if keyMask & ControlMask != 0 { formUnion(.control) }
        if keyMask & Mod1Mask != 0 { formUnion(.option) }
        if keyMask & Mod2Mask != 0 { formUnion(.numericPad) }
        if keyMask & Mod4Mask != 0 { formUnion(.command) }
    }
}

internal extension Event {
    convenience init?(x11Event: CX11.XEvent, timestamp: TimeInterval, windowNumber: Int) throws {
        guard let type = EventType(x11Event: x11Event) else {
            return nil
        }
        
        switch type {
        case _ where EventType.mouseEventTypes.contains(type):
            let buttonEvent = x11Event.xbutton
            
            try self.init(withMouseEventType: type, location: CGPoint(x: Int(buttonEvent.x), y: Int(buttonEvent.y)), modifierFlags: ModifierFlags(x11KeyMask: buttonEvent.state), timestamp: timestamp, windowNumber: windowNumber, eventNumber: 0, clickCount: 0, pressure: 0.0)
        default:
            return nil
        }
    }
}
