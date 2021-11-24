//
//  XInput2Button+Event.swift
//  AppKid
//
//  Created by Serhii Mumriak on 22.04.2020.
//

import Foundation
import CXlib
import SwiftXlib

internal extension XInput2Button {
    var downEventType: Event.EventType {
        switch self {
            case .none: return .none
            case .left: return .leftMouseDown
            case .right: return .rightMouseDown
            case .middle: return .otherMouseDown
            case .scrollUp: return .scrollWheel
            case .scrollDown: return .scrollWheel
            case .other(_): return .otherMouseDown
        }
    }

    var moveEventType: Event.EventType {
        switch self {
            case .none: return .mouseMoved
            case .left: return .leftMouseDragged
            case .right: return .rightMouseDragged
            case .middle: return .otherMouseDragged
            case .scrollUp: return .otherMouseDragged
            case .scrollDown: return .otherMouseDragged
            case .other(_): return .otherMouseDragged
        }
    }

    var upEventType: Event.EventType {
        switch self {
            case .none: return .none
            case .left: return .leftMouseUp
            case .right: return .rightMouseUp
            case .middle: return .otherMouseUp
            case .scrollUp: return .none // scroll wheel events are only handled for button down state
            case .scrollDown: return .none // scroll wheel events are only handled for button down state
            case .other(_): return .otherMouseUp
        }
    }
}

internal extension XIDeviceEvent {
    var button: XInput2Button {
        return XInput2Button(rawValue: detail)
    }
}

internal extension Event {
    var xInput2Button: XInput2Button {
        guard EventTypeMask.anyMouse.contains(type.mask) else {
            return .none
        }

        return XInput2Button(rawValue: CInt(buttonNumber))
    }
}
