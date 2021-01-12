//
//  Event.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation

public extension Event {
    enum EventType: UInt {
        case none = 0
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
        case windowUnmapped
        case windowExposed
        case applicationActivated
        case applicationDeactivated
        case windowMoved
        case windowDidResize
        case screenChanged
        case ignoredDisplayServerEvent // used to avoid double queueing of events when some X11 event is not parsable
        case windowDeleteRequest // WM_DELETE_WINDOW atom from X11
        case windowSyncRequest // _NET_WM_SYNC_REQUEST atom from X11
        case message // client message from X11
        case terminate // last event before stopping Run Loop
    }
}

public extension Event {
    struct ModifierFlags: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let none = Self([])
        public static let capsLock = Self(rawValue: 1 << 16)
        public static let shift = Self(rawValue: 1 << 17)
        public static let control = Self(rawValue: 1 << 18)
        public static let option = Self(rawValue: 1 << 19)
        public static let command = Self(rawValue: 1 << 20)
        public static let numericPad = Self(rawValue: 1 << 21)
        public static let help = Self(rawValue: 1 << 22)
        public static let function = Self(rawValue: 1 << 23)
    }
}

public extension Event {
    struct EventTypeMask: OptionSet {
        public typealias RawValue = UInt64
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let none = Self([])
        public static let leftMouseDown = Self(rawValue: 1 << EventType.leftMouseDown.rawValue)
        public static let leftMouseUp = Self(rawValue: 1 << EventType.leftMouseUp.rawValue)
        public static let rightMouseDown = Self(rawValue: 1 << EventType.rightMouseDown.rawValue)
        public static let rightMouseUp = Self(rawValue: 1 << EventType.rightMouseUp.rawValue)
        public static let mouseMoved = Self(rawValue: 1 << EventType.mouseMoved.rawValue)
        public static let leftMouseDragged = Self(rawValue: 1 << EventType.leftMouseDragged.rawValue)
        public static let rightMouseDragged = Self(rawValue: 1 << EventType.rightMouseDragged.rawValue)
        public static let mouseEntered = Self(rawValue: 1 << EventType.mouseEntered.rawValue)
        public static let mouseExited = Self(rawValue: 1 << EventType.mouseExited.rawValue)
        public static let keyDown = Self(rawValue: 1 << EventType.keyDown.rawValue)
        public static let keyUp = Self(rawValue: 1 << EventType.keyUp.rawValue)
        public static let flagsChanged = Self(rawValue: 1 << EventType.flagsChanged.rawValue)
        public static let appKidDefined = Self(rawValue: 1 << EventType.appKidDefined.rawValue)
        public static let systemDefined = Self(rawValue: 1 << EventType.systemDefined.rawValue)
        public static let applicationDefined = Self(rawValue: 1 << EventType.applicationDefined.rawValue)
        public static let periodic = Self(rawValue: 1 << EventType.periodic.rawValue)
        public static let cursorUpdate = Self(rawValue: 1 << EventType.cursorUpdate.rawValue)
        public static let scrollWheel = Self(rawValue: 1 << EventType.scrollWheel.rawValue)
//        public static let tabletPoint = Self(rawValue: 1 << EventType.tabletPoint.rawValue)
//        public static let tabletProximity = Self(rawValue: 1 << EventType.tabletProximity.rawValue)
        public static let otherMouseDown = Self(rawValue: 1 << EventType.otherMouseDown.rawValue)
        public static let otherMouseUp = Self(rawValue: 1 << EventType.otherMouseUp.rawValue)
        public static let otherMouseDragged = Self(rawValue: 1 << EventType.otherMouseDragged.rawValue)
        
//        public static let gesture = Self(rawValue: 1 << EventType.gesture.rawValue)
//        public static let magnify = Self(rawValue: 1 << EventType.magnify.rawValue)
//        public static let swipe = Self(rawValue: 1 << EventType.swipe.rawValue)
//        public static let rotate = Self(rawValue: 1 << EventType.rotate.rawValue)
//        public static let beginGesture = Self(rawValue: 1 << EventType.beginGesture.rawValue)
//        public static let endGesture = Self(rawValue: 1 << EventType.endGesture.rawValue)
//        public static let smartMagnify = Self(rawValue: 1 << EventType.smartMagnify.rawValue)
//        public static let pressure = Self(rawValue: 1 << EventType.pressure.rawValue)
//        public static let directTouch = Self(rawValue: 1 << EventType.directTouch.rawValue)
//        public static let changeMode = Self(rawValue: 1 << EventType.changeMode.rawValue)
        
        public static let any = Self(rawValue: RawValue.max)
        
        static func from(eventType: EventType) -> EventTypeMask {
            return EventTypeMask(rawValue: 1 << eventType.rawValue)
        }
    }
}

public extension Event.EventTypeMask {
    static let anyMouse: Self = [
        .anyMouseDown,
        .anyMouseUp,
        .anyMouseDragged,
        .mouseMoved,
        .scrollWheel,
    ]

    static let anyMouseDown: Self = [
        .leftMouseDown,
        .rightMouseDown,
        .otherMouseDown,
    ]

    static let anyMouseUp: Self = [
        .leftMouseUp,
        .rightMouseUp,
        .otherMouseUp,
    ]

    static let anyMouseDragged: Self = [
        .leftMouseDragged,
        .rightMouseDragged,
        .otherMouseDragged,
    ]

    static let anyKeyboard: Self = [
        .keyDown,
        .keyUp,
    ]
}

public extension Event {
    enum EventCreationError: Error, CustomDebugStringConvertible {
        case eventIgnored(description: String)
        case nativeEventIgnored(description: String)
        case noWindow(description: String)
        case incompatibleEventType

        public var debugDescription: String {
            switch self {
            case .eventIgnored(let description):
                return "Event ignored. " + description
            case .nativeEventIgnored(let description):
                return "Native event ignored. " + description
            case .noWindow(let description):
                return "No window for event. " + description
            case .incompatibleEventType:
                return "Incompatible event type"
            }
        }
    }
}

public class Event: NSObject {
    public internal(set) var type: EventType = .none
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

    public internal(set) var isARepeat: Bool = false
    public internal(set) var keyCode: UInt32 = 0
    public internal(set) var characters: String? = nil
    public internal(set) var charactersIgnoringModifiers: String? = nil

    internal var syncCounter: Int64 = 0 // store the sync counter received from _NET_WM_SYNC_REQUEST

    internal static func ignoredDisplayServerEvent() -> Event {
        let result = Event(type: .appKidDefined, location: .nan, modifierFlags: .none, windowNumber: NSNotFound)
        result.subType = .ignoredDisplayServerEvent
        return result
    }
    
    internal init(type: EventType, location: CGPoint, modifierFlags: ModifierFlags, windowNumber: Int) {
        self.type = type
        self.locationInWindow = location
        self.modifierFlags = modifierFlags
        self.windowNumber = windowNumber
        self.window = Application.shared.window(number: windowNumber)

        super.init()
    }
    
    public convenience init(withMouseEventType type: EventType, location: CGPoint, modifierFlags: ModifierFlags, timestamp: TimeInterval, windowNumber: Int, eventNumber: Int, clickCount: Int, pressure: CGFloat) throws {
        guard type.isAnyMouse else {
            throw EventCreationError.incompatibleEventType
        }
        
        self.init(type: type, location: location, modifierFlags: modifierFlags, windowNumber: windowNumber)
    }
    
    internal convenience init(withAppKidEventSubType subType: EventSubtype, windowNumber: Int) {
        self.init(type: .appKidDefined, location: CGPoint(x: CGFloat.nan, y: CGFloat.nan), modifierFlags: .none, windowNumber: windowNumber)
        self.subType = subType
    }
}

extension Event {
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

internal extension Event.EventType {
    var isAnyMouse: Bool {
        return Event.EventTypeMask.anyMouse.contains(mask)
    }

    var isAnyMouseDown: Bool {
        return Event.EventTypeMask.anyMouseDown.contains(mask)
    }

    var isAnyMouseUp: Bool {
        return Event.EventTypeMask.anyMouseUp.contains(mask)
    }

    var isAnyMouseDragged: Bool {
        return Event.EventTypeMask.anyMouseDragged.contains(mask)
    }

    var isAnyKeyboard: Bool {
        return Event.EventTypeMask.anyKeyboard.contains(mask)
    }
}

internal extension Event {
    var isAnyMouseEvent: Bool {
        return type.isAnyMouse
    }

    var isAnyMouseDownEvent: Bool {
        return type.isAnyMouseDown
    }

    var isAnyMouseUpEvent: Bool {
        return type.isAnyMouseUp
    }

    var isAnyMouseDraggedEvent: Bool {
        return type.isAnyMouseDragged
    }

    var isAnyKeyboardEvent: Bool {
        return type.isAnyKeyboard
    }
}
