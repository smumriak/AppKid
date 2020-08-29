//
//  X11EventType+Debug.swift
//  AppKid
//
//  Created by Serhii Mumriak on 22.04.2020.
//

import Foundation
import CXlib

extension X11EventType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .keyPress: return "KeyPress"
        case .keyRelease: return "KeyRelease"
        case .buttonPress: return "ButtonPress"
        case .buttonRelease: return "ButtonRelease"
        case .motionNotify: return "MotionNotify"
        case .enterNotify: return "EnterNotify"
        case .leaveNotify: return "LeaveNotify"
        case .focusIn: return "FocusIn"
        case .focusOut: return "FocusOut"
        case .keymapNotify: return "KeymapNotify"
        case .expose: return "Expose"
        case .graphicsExpose: return "GraphicsExpose"
        case .noExpose: return "NoExpose"
        case .visibilityNotify: return "VisibilityNotify"
        case .createNotify: return "CreateNotify"
        case .destroyNotify: return "DestroyNotify"
        case .unmapNotify: return "UnmapNotify"
        case .mapNotify: return "MapNotify"
        case .mapRequest: return "MapRequest"
        case .reparentNotify: return "ReparentNotify"
        case .configureNotify: return "ConfigureNotify"
        case .configureRequest: return "ConfigureRequest"
        case .gravityNotify: return "GravityNotify"
        case .resizeRequest: return "ResizeRequest"
        case .circulateNotify: return "CirculateNotify"
        case .circulateRequest: return "CirculateRequest"
        case .propertyNotify: return "PropertyNotify"
        case .selectionClear: return "SelectionClear"
        case .selectionRequest: return "SelectionRequest"
        case .selectionNotify: return "SelectionNotify"
        case .colormapNotify: return "ColormapNotify"
        case .clientMessage: return "ClientMessage"
        case .mappingNotify: return "MappingNotify"
        case .genericEvent: return "GenericEvent"
        @unknown default: return "Unknown, code: \(rawValue)"
        }
    }
}
