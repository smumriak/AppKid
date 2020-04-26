//
//  XEvent+Event.swift
//  AppKid
//
//  Created by Serhii Mumriak on 22.04.2020.
//

import Foundation
import CoreFoundation
import CX11.X
import CX11.Xlib
import CXInput2

internal extension XEvent {
    func isCookie(with extension: CInt) -> Bool {
        return type == GenericEvent && xcookie.extension == `extension`
    }

    var x11EventType: X11EventType? {
        return X11EventType(rawValue: type)
    }
}

internal extension XGenericEventCookie {
    var xInput2EventType: XInput2EventType? {
        return XInput2EventType(rawValue: evtype)
    }
}

internal extension XButtonEvent {
    var buttonName: X11EventButtonName? {
        return X11EventButtonName(rawValue: CInt(button))
    }
}

internal extension XMotionEvent {
    var buttonMask: X11EventButtonMask {
        return X11EventButtonMask(rawValue: CInt(state))
    }
}

internal extension XEvent {
    var deviceEvent: XIDeviceEvent {
        get {
            return xcookie.data.assumingMemoryBound(to: XIDeviceEvent.self).pointee
        }
        set {
            xcookie.data.assumingMemoryBound(to: XIDeviceEvent.self).pointee = newValue
        }
    }
}

internal extension XIDeviceEvent {
    var generatedKeyPressedEvent: XKeyPressedEvent {
        return XKeyPressedEvent(type: KeyPress,
                                serial: serial,
                                send_event: send_event,
                                display: display,
                                window: event,
                                root: root,
                                subwindow: child,
                                time: time,
                                x: CInt(event_x),
                                y: CInt(event_y),
                                x_root: CInt(root_x),
                                y_root: CInt(root_y),
                                state: UInt32(mods.effective | group.effective << 13),
                                keycode: CUnsignedInt(detail),
                                same_screen: 1)
    }
}

internal extension X11EventTypeMask {
    static let keyboard: X11EventTypeMask = [.keyPress, .keyRelease]
    static let mouse: X11EventTypeMask = [.buttonPress, .buttonRelease]
    static let enterLeave: X11EventTypeMask = [.enterWindow, .leaveWindow]
    static let geometry: X11EventTypeMask = [.exposure, .visibilityChange, .structureNotify]

    static let basic: X11EventTypeMask = [
        .keyboard,
        .mouse,
        .buttonMotion,
        .enterLeave,
        .focusChange,
        .geometry]
}

internal extension XInput2EventTypeMask {
    static let keyboard: XInput2EventTypeMask = [.keyPress, .keyRelease]
    static let mouse: XInput2EventTypeMask = [.buttonPress, .buttonRelease]
    static let enterLeave: XInput2EventTypeMask = [.enter, .leave]
    static let focus: XInput2EventTypeMask = [.focusIn, .focusOut]

    static let basic: XInput2EventTypeMask = [
        .keyboard,
        .mouse,
        .motion,
        .enterLeave,
        .focus]
}
