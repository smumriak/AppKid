//
//  Event+XInput2.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.04.2020.
//

import Foundation
import CoreFoundation
import CX11.X
import CX11.Xlib
import CXInput2

internal extension XInput2EventTypeMask {
    static let keyboard: XInput2EventTypeMask = [.keyPress, .keyRelease]
    static let mouse: XInput2EventTypeMask = [.buttonPress, .buttonRelease]
    static let enterLeave: XInput2EventTypeMask = [.enter, .leave]
    static let focus: XInput2EventTypeMask = [.focusIn, .focusOut]

    static let basic: XInput2EventTypeMask = [.keyboard, .mouse, .motion, .enterLeave, .focus]
}

internal extension Event.EventType {
    init(xInput2Event: XEvent) {
        guard let type = XInput2EventType(rawValue: xInput2Event.xcookie.evtype) else {
            self = .noEvent
            return
        }

        switch type {
        case .keyPress, .keyRelease:
            self = Self.keyboardEventType(for: xInput2Event.deviceEvent, type: type)

        case .buttonPress, .buttonRelease:
            self = Self.mouseEventType(for: xInput2Event.deviceEvent, type: type)

        case .enter:
            self = .mouseEntered
            
        case .leave:
            self = .mouseExited
            
        default:
            self = .noEvent
        }
    }
}

fileprivate extension Event.EventType {
    static func keyboardEventType(for event: XIDeviceEvent, type: XInput2EventType) -> Self {
        switch type {
        case .keyPress: return .keyDown
        case .keyRelease: return .keyUp
        default: return .noEvent
        }
    }

    static func mouseEventType(for event: XIDeviceEvent, type: XInput2EventType) -> Self {
        switch type {
        case .buttonPress: return .leftMouseDown
        case .buttonRelease: return .leftMouseUp
        default: return .noEvent
        }
    }
}

internal extension Event {
    convenience init(xInput2Event: XEvent, timestamp: TimeInterval, displayScale: CGFloat) throws {
        let type = EventType(xInput2Event: xInput2Event)

        if type == .noEvent {
            throw EventCreationError.eventIgnored
        }

        let deviceEvent: XIDeviceEvent = xInput2Event.xcookie.data.assumingMemoryBound(to: XIDeviceEvent.self).pointee

        guard let windowNumber = Application.shared.windows.firstIndex(where: { $0.nativeWindow.windowID == deviceEvent.event }) else {
            throw EventCreationError.noWindow
        }

        switch type {
        case _ where EventType.mouseEventTypes.contains(type):
            debugPrint("Making mouse event")
            let deviceEvent = xInput2Event.deviceEvent

            let location = CGPoint(x: CGFloat(deviceEvent.event_x) / displayScale, y: CGFloat(deviceEvent.event_y) / displayScale)
//            ModifierFlags(x11KeyMask: deviceEvent.state)
            try self.init(withMouseEventType: type, location: location, modifierFlags: .none, timestamp: timestamp, windowNumber: windowNumber, eventNumber: 0, clickCount: 0, pressure: 0.0)

//            buttonNumber = 0

        default:
            throw EventCreationError.eventIgnored
        }
    }
}

fileprivate extension XEvent {
    var deviceEvent: XIDeviceEvent {
        return xcookie.data.assumingMemoryBound(to: XIDeviceEvent.self).pointee
    }
}
