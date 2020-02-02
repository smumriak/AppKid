//
//  Event.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation

public enum EventType {
    case leftMouseDown
    case leftMouseUp
    case rightMouseDown
    case rightMouseUp
    case mouseMoved
    case leftMouseDragged
    case rightMouseDragged
    case mouseEntered
    case mouseExited
    case keyDown
    case keyUp
    case flagsChanged
//    case appKidDefined // unimplemented
//    case systemDefined // unimplemented
    case applicationDefined
    case periodic
    case cursorUpdate
    case scrollWheel
    case tabletPoint
    case tabletProximity
    case otherMouseDown
    case otherMouseUp
    case otherMouseDragged
    
//    case gesture // unimplemented
//    case magnify // unimplemented
//    case swipe // unimplemented
//    case rotate // unimplemented
//    case beginGesture // unimplemented
//    case endGesture // unimplemented
//    case smartMagnify // unimplemented
//    case quickLook // unimplemented
//    case pressure // unimplemented
//    case directTouch // unimplemented
//    case changeMode // unimplemented
}

open class Event {
    public internal(set) var type: EventType
    
    init(type: EventType) {
        self.type = type
    }
}
