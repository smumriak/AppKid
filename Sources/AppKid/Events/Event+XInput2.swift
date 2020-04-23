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

fileprivate extension XEvent {
    var eventTypeFromXInput2Event: Event.EventType {
        switch xcookie.xInput2EventType {
        case .keyPress, .keyRelease:
            return keyboardEventType

        case .buttonPress, .buttonRelease, .motion:
            return mouseEventType

        case .enter:
            return .mouseEntered

        case .leave:
            return .mouseExited

        default:
            return .noEvent
        }
    }
}

fileprivate extension XEvent {
    var keyboardEventType: Event.EventType {
        switch xcookie.xInput2EventType {
        case .keyPress: return .keyDown
        case .keyRelease: return .keyUp
        default: return .noEvent
        }
    }

    var mouseEventType: Event.EventType {
        switch xcookie.xInput2EventType {
        case .buttonPress: return deviceEvent.button.downEventType
        case .buttonRelease: return deviceEvent.button.upEventType
        case .motion: return deviceEvent.button.moveEventType
        default: return .noEvent
        }
    }
}

internal extension Event {
    convenience init(xInput2Event: XEvent, timestamp: TimeInterval, displayServer: DisplayServer) throws {
        let type = xInput2Event.eventTypeFromXInput2Event

        if type == .noEvent {
            let eventString = xInput2Event.xcookie.xInput2EventType.map { String(reflecting: $0) } ?? "unknown"
            throw EventCreationError.nativeEventIgnored(description: "XInput2 event type: \(eventString)")
        }

        let deviceEvent: XIDeviceEvent = xInput2Event.deviceEvent

        guard let windowNumber = Application.shared.windows.firstIndex(where: { $0.nativeWindow.windowID == deviceEvent.event }) else {
            let eventString = xInput2Event.xcookie.xInput2EventType.map { String(reflecting: $0) } ?? "unknown"
            throw EventCreationError.noWindow(description: "XInput2 event type: \(eventString). Foreign window ID: \(deviceEvent.event)")
        }

        switch type {
        case _ where EventType.mouseEventTypes.contains(type):
            let deviceEvent = xInput2Event.deviceEvent
            let location = CGPoint(x: CGFloat(deviceEvent.event_x) / displayServer.displayScale, y: CGFloat(deviceEvent.event_y) / displayServer.displayScale)
//            ModifierFlags(x11KeyMask: deviceEvent.state)
            try self.init(withMouseEventType: type, location: location, modifierFlags: .none, timestamp: timestamp, windowNumber: windowNumber, eventNumber: 0, clickCount: 0, pressure: 0.0)

            buttonNumber = Int(deviceEvent.detail)

        default:
            throw EventCreationError.eventIgnored(description: "Event type: \(type)")
        }
    }
}
