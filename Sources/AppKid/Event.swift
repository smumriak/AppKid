//
//  Event.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation

public extension Event {
    enum EventType {
        case noEvent
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
        case appKidDefined
        case systemDefined
        case applicationDefined
        case periodic
        case cursorUpdate
        case scrollWheel
        //    case tabletPoint // unimplemented
        //    case tabletProximity // unimplemented
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
        
        static let mouseEventTypes: Set<EventType> = [
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
            .mouseMoved,
            .leftMouseDragged,
            .rightMouseDragged,
            .scrollWheel,
            .otherMouseDown,
            .otherMouseUp,
            .otherMouseDragged
        ]
    }
}

public extension Event {
    struct ModifierFlags: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let none = ModifierFlags(rawValue: 1 << 16)
        public static let capsLock = ModifierFlags(rawValue: 1 << 16)
        public static let shift = ModifierFlags(rawValue: 1 << 17)
        public static let control = ModifierFlags(rawValue: 1 << 18)
        public static let option = ModifierFlags(rawValue: 1 << 19)
        public static let command = ModifierFlags(rawValue: 1 << 20)
        public static let numericPad = ModifierFlags(rawValue: 1 << 21)
        public static let help = ModifierFlags(rawValue: 1 << 22)
        public static let function = ModifierFlags(rawValue: 1 << 23)
    }
}

public extension Event {
    enum EventCreationError: Error {
        case incompatibleEventType(validEventTypes: Set<EventType>)
    }
}

open class Event {
    public fileprivate(set) var type: EventType = .noEvent
    public fileprivate(set) var modifierFlags: ModifierFlags = .none
    public fileprivate(set) var timestamp: TimeInterval = 0.0
    public fileprivate(set) var window: Window? = nil
    public fileprivate(set) var windowNumber: Int = NSNotFound
    
    public fileprivate(set) var clickCount: Int = 0
    public fileprivate(set) var buttonNumber: Int = 0
    public fileprivate(set) var eventNumber: Int = 0
    public fileprivate(set) var pressure: Float = 0.0
    public fileprivate(set) var locationInWindow: CGPoint = .zero
    
    public fileprivate(set) var deltaX: Float = 0.0
    public fileprivate(set) var deltaY: Float = 0.0
    public fileprivate(set) var deltaZ: Float = 0.0
    
    public fileprivate(set) var hasPreciseScrollingDeltas: Bool = false
    
    public fileprivate(set) var scrollingDeltaX: Float = 0.0
    public fileprivate(set) var scrollingDeltaY: Float = 0.0
    public fileprivate(set) var isDirectionInvertedFromDevice: Bool = false

    public init() {}
    
    convenience public init(withMouseEventType type: EventType, location: CGPoint, modifierFlags: ModifierFlags, timestamp: TimeInterval, windowNumber: Int, eventNumber: Int, clickCount: Int, pressure: Float) throws {
        self.init()

        guard EventType.mouseEventTypes.contains(type) else {
            throw EventCreationError.incompatibleEventType(validEventTypes: EventType.mouseEventTypes)
        }
        
        self.type = type
        self.modifierFlags = modifierFlags
        self.timestamp = timestamp
        self.window = Application.shared.window(number: windowNumber)
        self.windowNumber = windowNumber
        self.locationInWindow = location
    }
}
