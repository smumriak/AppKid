//
//  Event.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation

public extension Event {
    enum EventType: UInt {
        case noEvent = 0
        case leftMouseDown = 1
        case leftMouseUp = 2
        case rightMouseDown = 3
        case rightMouseUp = 4
        case mouseMoved = 5
        case leftMouseDragged = 6
        case rightMouseDragged = 7
        case mouseEntered = 8
        case mouseExited = 9
        case keyDown = 10
        case keyUp = 11
        case flagsChanged = 12
        case appKidDefined = 13
        case systemDefined = 14
        case applicationDefined = 15
        case periodic = 16
        case cursorUpdate = 17
        
        case scrollWheel = 22
//        case tabletPoint = 23
//        case tabletProximity = 24
        case otherMouseDown = 25
        case otherMouseUp = 26
        case otherMouseDragged = 27
        
//        case gesture = 29
//        case magnify = 30
//        case swipe = 31
//        case rotate = 18
//        case beginGesture = 19
//        case endGesture = 20
//        case smartMagnify = 32
//        case quickLook = 33
//        case pressure = 34
//        case directTouch = 37
//        case changeMode = 38
        
        
        
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
        
        var mask: EventTypeMask {
            return EventTypeMask(rawValue: 1 << rawValue)
        }
    }
}

public extension Event {
    enum EventSubtype: UInt {
        case none
        // AppKidDefined Type
        case windowExposed
        case applicationActivated
        case applicationDeactivated
        case windowMoved
        case screenChanged
    }
}

public extension Event {
    struct ModifierFlags: OptionSet {
        public typealias RawValue = UInt32
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let none = ModifierFlags(rawValue: 0)
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
    struct EventTypeMask : OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        public static let none = EventTypeMask(rawValue: 0)
        public static var leftMouseDown = EventTypeMask(rawValue: 1 << EventType.leftMouseDown.rawValue)
        public static var leftMouseUp = EventTypeMask(rawValue: 1 << EventType.leftMouseUp.rawValue)
        public static var rightMouseDown = EventTypeMask(rawValue: 1 << EventType.rightMouseDown.rawValue)
        public static var rightMouseUp = EventTypeMask(rawValue: 1 << EventType.rightMouseUp.rawValue)
        public static var mouseMoved = EventTypeMask(rawValue: 1 << EventType.mouseMoved.rawValue)
        public static var leftMouseDragged = EventTypeMask(rawValue: 1 << EventType.leftMouseDragged.rawValue)
        public static var rightMouseDragged = EventTypeMask(rawValue: 1 << EventType.rightMouseDragged.rawValue)
        public static var mouseEntered = EventTypeMask(rawValue: 1 << EventType.mouseEntered.rawValue)
        public static var mouseExited = EventTypeMask(rawValue: 1 << EventType.mouseExited.rawValue)
        public static var keyDown = EventTypeMask(rawValue: 1 << EventType.keyDown.rawValue)
        public static var keyUp = EventTypeMask(rawValue: 1 << EventType.keyUp.rawValue)
        public static var flagsChanged = EventTypeMask(rawValue: 1 << EventType.flagsChanged.rawValue)
        public static var appKidDefined = EventTypeMask(rawValue: 1 << EventType.appKidDefined.rawValue)
        public static var systemDefined = EventTypeMask(rawValue: 1 << EventType.systemDefined.rawValue)
        public static var applicationDefined = EventTypeMask(rawValue: 1 << EventType.applicationDefined.rawValue)
        public static var periodic = EventTypeMask(rawValue: 1 << EventType.periodic.rawValue)
        public static var cursorUpdate = EventTypeMask(rawValue: 1 << EventType.cursorUpdate.rawValue)
        public static var scrollWheel = EventTypeMask(rawValue: 1 << EventType.scrollWheel.rawValue)
//        public static var tabletPoint = EventTypeMask(rawValue: 1 << EventType.tabletPoint.rawValue)
//        public static var tabletProximity = EventTypeMask(rawValue: 1 << EventType.tabletProximity.rawValue)
        public static var otherMouseDown = EventTypeMask(rawValue: 1 << EventType.otherMouseDown.rawValue)
        public static var otherMouseUp = EventTypeMask(rawValue: 1 << EventType.otherMouseUp.rawValue)
        public static var otherMouseDragged = EventTypeMask(rawValue: 1 << EventType.otherMouseDragged.rawValue)
        
//        public static var gesture = EventTypeMask(rawValue: 1 << EventType.gesture.rawValue)
//        public static var magnify = EventTypeMask(rawValue: 1 << EventType.magnify.rawValue)
//        public static var swipe = EventTypeMask(rawValue: 1 << EventType.swipe.rawValue)
//        public static var rotate = EventTypeMask(rawValue: 1 << EventType.rotate.rawValue)
//        public static var beginGesture = EventTypeMask(rawValue: 1 << EventType.beginGesture.rawValue)
//        public static var endGesture = EventTypeMask(rawValue: 1 << EventType.endGesture.rawValue)
//        public static var smartMagnify = EventTypeMask(rawValue: 1 << EventType.smartMagnify.rawValue)
//        public static var pressure = EventTypeMask(rawValue: 1 << EventType.pressure.rawValue)
//        public static var directTouch = EventTypeMask(rawValue: 1 << EventType.directTouch.rawValue)
//        public static var changeMode = EventTypeMask(rawValue: 1 << EventType.changeMode.rawValue)
        
        public static var any = EventTypeMask(rawValue: UInt.max)
        
        static func from(eventType: EventType) -> EventTypeMask {
            return EventTypeMask(rawValue: 1 << eventType.rawValue)
        }
    }
}

public extension Event {
    enum EventCreationError: Error {
        case incompatibleEventType(validEventTypes: Set<EventType>)
    }
}

open class Event {
    public internal(set) var type: EventType = .noEvent
    public internal(set) var subType: EventSubtype = .none
    public internal(set) var modifierFlags: ModifierFlags = .none
    public internal(set) var timestamp: TimeInterval = 0.0
    public internal(set) var window: Window? = nil
    public internal(set) var windowNumber: Int = NSNotFound
    
    public internal(set) var clickCount: Int = 0
    public internal(set) var buttonNumber: Int = 0
    public internal(set) var eventNumber: Int = 0
    public internal(set) var pressure: Float = 0.0
    public internal(set) var locationInWindow: CGPoint = .zero
    
    public internal(set) var deltaX: Float = 0.0
    public internal(set) var deltaY: Float = 0.0
    public internal(set) var deltaZ: Float = 0.0
    
    public internal(set) var hasPreciseScrollingDeltas: Bool = false
    
    public internal(set) var scrollingDeltaX: Float = 0.0
    public internal(set) var scrollingDeltaY: Float = 0.0
    public internal(set) var isDirectionInvertedFromDevice: Bool = false

    internal init(type: EventType, location: CGPoint, modifierFlags: ModifierFlags, window: Window?) {
        self.type = type
        self.locationInWindow = location
        self.modifierFlags = modifierFlags
        self.window = window
    }
    
    convenience public init(withMouseEventType type: EventType, location: CGPoint, modifierFlags: ModifierFlags, timestamp: TimeInterval, windowNumber: Int, eventNumber: Int, clickCount: Int, pressure: Float) throws {
        guard EventType.mouseEventTypes.contains(type) else {
            throw EventCreationError.incompatibleEventType(validEventTypes: EventType.mouseEventTypes)
        }
        
        self.init(type: type, location: location, modifierFlags: modifierFlags, window: Application.shared.window(number: windowNumber))
        
    }
}
