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
        case windowMapped
        case windowExposed
        case applicationActivated
        case applicationDeactivated
        case windowMoved
        case windowResized
        case screenChanged
        case message // client message from X11
        case last // last event before stopping Run Loop
    }
}

public extension Event {
    struct ModifierFlags: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let none = ModifierFlags([])
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
        public static let none = EventTypeMask([])
        public static let leftMouseDown = EventTypeMask(rawValue: 1 << EventType.leftMouseDown.rawValue)
        public static let leftMouseUp = EventTypeMask(rawValue: 1 << EventType.leftMouseUp.rawValue)
        public static let rightMouseDown = EventTypeMask(rawValue: 1 << EventType.rightMouseDown.rawValue)
        public static let rightMouseUp = EventTypeMask(rawValue: 1 << EventType.rightMouseUp.rawValue)
        public static let mouseMoved = EventTypeMask(rawValue: 1 << EventType.mouseMoved.rawValue)
        public static let leftMouseDragged = EventTypeMask(rawValue: 1 << EventType.leftMouseDragged.rawValue)
        public static let rightMouseDragged = EventTypeMask(rawValue: 1 << EventType.rightMouseDragged.rawValue)
        public static let mouseEntered = EventTypeMask(rawValue: 1 << EventType.mouseEntered.rawValue)
        public static let mouseExited = EventTypeMask(rawValue: 1 << EventType.mouseExited.rawValue)
        public static let keyDown = EventTypeMask(rawValue: 1 << EventType.keyDown.rawValue)
        public static let keyUp = EventTypeMask(rawValue: 1 << EventType.keyUp.rawValue)
        public static let flagsChanged = EventTypeMask(rawValue: 1 << EventType.flagsChanged.rawValue)
        public static let appKidDefined = EventTypeMask(rawValue: 1 << EventType.appKidDefined.rawValue)
        public static let systemDefined = EventTypeMask(rawValue: 1 << EventType.systemDefined.rawValue)
        public static let applicationDefined = EventTypeMask(rawValue: 1 << EventType.applicationDefined.rawValue)
        public static let periodic = EventTypeMask(rawValue: 1 << EventType.periodic.rawValue)
        public static let cursorUpdate = EventTypeMask(rawValue: 1 << EventType.cursorUpdate.rawValue)
        public static let scrollWheel = EventTypeMask(rawValue: 1 << EventType.scrollWheel.rawValue)
//        public static let tabletPoint = EventTypeMask(rawValue: 1 << EventType.tabletPoint.rawValue)
//        public static let tabletProximity = EventTypeMask(rawValue: 1 << EventType.tabletProximity.rawValue)
        public static let otherMouseDown = EventTypeMask(rawValue: 1 << EventType.otherMouseDown.rawValue)
        public static let otherMouseUp = EventTypeMask(rawValue: 1 << EventType.otherMouseUp.rawValue)
        public static let otherMouseDragged = EventTypeMask(rawValue: 1 << EventType.otherMouseDragged.rawValue)
        
//        public static let gesture = EventTypeMask(rawValue: 1 << EventType.gesture.rawValue)
//        public static let magnify = EventTypeMask(rawValue: 1 << EventType.magnify.rawValue)
//        public static let swipe = EventTypeMask(rawValue: 1 << EventType.swipe.rawValue)
//        public static let rotate = EventTypeMask(rawValue: 1 << EventType.rotate.rawValue)
//        public static let beginGesture = EventTypeMask(rawValue: 1 << EventType.beginGesture.rawValue)
//        public static let endGesture = EventTypeMask(rawValue: 1 << EventType.endGesture.rawValue)
//        public static let smartMagnify = EventTypeMask(rawValue: 1 << EventType.smartMagnify.rawValue)
//        public static let pressure = EventTypeMask(rawValue: 1 << EventType.pressure.rawValue)
//        public static let directTouch = EventTypeMask(rawValue: 1 << EventType.directTouch.rawValue)
//        public static let changeMode = EventTypeMask(rawValue: 1 << EventType.changeMode.rawValue)
        
        public static let any = EventTypeMask(rawValue: UInt.max)
        
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

public class Event {
    public internal(set) var type: EventType = .noEvent
    public internal(set) var subType: EventSubtype = .none
    public internal(set) var modifierFlags: ModifierFlags = .none
    public internal(set) var timestamp: TimeInterval = .zero
    public internal(set) var window: Window? = nil
    public internal(set) var windowNumber: Int
    
    public internal(set) var clickCount: Int = .zero
    public internal(set) var buttonNumber: Int = .zero
    public internal(set) var eventNumber: Int = .zero
    public internal(set) var pressure: CGFloat = .zero
    public internal(set) var locationInWindow: CGPoint = CGPoint(x: CGFloat.nan, y: CGFloat.nan)
    
    public internal(set) var deltaX: CGFloat = .zero
    public internal(set) var deltaY: CGFloat = .zero
    public internal(set) var deltaZ: CGFloat = .zero
    
    public internal(set) var hasPreciseScrollingDeltas: Bool = false
    
    public internal(set) var scrollingDeltaX: CGFloat = .zero
    public internal(set) var scrollingDeltaY: CGFloat = .zero
    public internal(set) var isDirectionInvertedFromDevice: Bool = false
    
    internal init(type: EventType, location: CGPoint, modifierFlags: ModifierFlags, windowNumber: Int) {
        self.type = type
        self.locationInWindow = location
        self.modifierFlags = modifierFlags
        self.windowNumber = windowNumber
        self.window = Application.shared.window(number: windowNumber)
    }
    
    convenience public init(withMouseEventType type: EventType, location: CGPoint, modifierFlags: ModifierFlags, timestamp: TimeInterval, windowNumber: Int, eventNumber: Int, clickCount: Int, pressure: CGFloat) throws {
        guard EventType.mouseEventTypes.contains(type) else {
            throw EventCreationError.incompatibleEventType(validEventTypes: EventType.mouseEventTypes)
        }
        
        self.init(type: type, location: location, modifierFlags: modifierFlags, windowNumber: windowNumber)
    }
    
    convenience internal init(withAppKidEventSubType subType: EventSubtype, windowNumber: Int) {
        self.init(type: .appKidDefined, location: .zero, modifierFlags: .none, windowNumber: windowNumber)
        self.subType = subType
    }
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.type == rhs.type &&
            lhs.subType == rhs.subType &&
            lhs.modifierFlags == rhs.modifierFlags &&
            lhs.timestamp == rhs.timestamp &&
            lhs.window == rhs.window &&
            lhs.windowNumber == rhs.windowNumber &&
            lhs.clickCount == rhs.clickCount &&
            lhs.buttonNumber == rhs.buttonNumber &&
            lhs.eventNumber == rhs.eventNumber &&
            lhs.pressure == rhs.pressure &&
            lhs.locationInWindow == rhs.locationInWindow &&
            lhs.deltaX == rhs.deltaX &&
            lhs.deltaY == rhs.deltaY &&
            lhs.deltaZ == rhs.deltaZ &&
            lhs.hasPreciseScrollingDeltas == rhs.hasPreciseScrollingDeltas &&
            lhs.scrollingDeltaX == rhs.scrollingDeltaX &&
            lhs.scrollingDeltaY == rhs.scrollingDeltaY &&
            lhs.isDirectionInvertedFromDevice == rhs.isDirectionInvertedFromDevice
    }
}
