//
//  XInput2EventType+Debug.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 22.04.2020.
//

import Foundation
import CXlib

extension XInput2EventType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .deviceChanged: return "DeviceChanged"
        case .keyPress: return "KeyPress"
        case .keyRelease: return "KeyRelease"
        case .buttonPress: return "ButtonPress"
        case .buttonRelease: return "ButtonRelease"
        case .motion: return "Motion"
        case .enter: return "Enter"
        case .leave: return "Leave"
        case .focusIn: return "FocusIn"
        case .focusOut: return "FocusOut"
        case .hierarchyChanged: return "HierarchyChanged"
        case .propertyEvent: return "PropertyEvent"
        case .rawKeyPress: return "RawKeyPress"
        case .rawKeyRelease: return "RawKeyRelease"
        case .rawButtonPress: return "RawButtonPress"
        case .rawButtonRelease: return "RawButtonRelease"
        case .rawMotion: return "RawMotion"
        case .touchBegin: return "TouchBegin"
        case .touchUpdate: return "TouchUpdate"
        case .touchEnd: return "TouchEnd"
        case .touchOwnership: return "TouchOwnership"
        case .rawTouchBegin: return "RawTouchBegin"
        case .rawTouchUpdate: return "RawTouchUpdate"
        case .rawTouchEnd: return "RawTouchEnd"
        case .barrierHit: return "BarrierHit"
        case .barrierLeave: return "BarrierLeave"
        @unknown default: return "Unknown, code: \(rawValue)"
        }
    }
}
