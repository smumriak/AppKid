//
//  Control.swift
//  AppKid
//
//  Created by Serhii Mumriak on 07.02.2020.
//

import Foundation

open class Control: View, ControlProtocol {
    var lastLocationsForMouseButton: [Int: CGPoint] = [:]

    open var isEnabled: Bool {
        get {
            return state.contains(.disabled) == false
        }
        set {
            if newValue {
                state = state.subtracting(.disabled)
            } else {
                state = state.union(.disabled)
            }
        }
    }

    open var isSelected: Bool {
        get {
            return state.contains(.selected)
        }
        set {
            if newValue {
                state = state.union(.selected)
            } else {
                state = state.subtracting(.selected)
            }
        }
    }

    open var isHighlighted: Bool {
        get {
            return state.contains(.highlighted)
        }
        set {
            if newValue {
                state = state.union(.highlighted)
            } else {
                state = state.subtracting(.highlighted)
            }
        }
    }

    internal(set) open var state: State = .normal

    // MARK: Mouse Events

    open override func mouseDown(with event: Event) {
        isHighlighted = true
        lastLocationsForMouseButton[event.buttonNumber] = convert(event.locationInWindow, from: window)

        sendActions(for: .mouseDown, with: event)
    }

    open override func mouseDragged(with event: Event) {
        let location = convert(event.locationInWindow, from: window)

        let previousLocation = lastLocationsForMouseButton[event.buttonNumber] ?? CGPoint(x: CGFloat.nan, y: CGFloat.nan)
        lastLocationsForMouseButton[event.buttonNumber] = location

        if point(inside: location) {
            isHighlighted = true

            if point(inside: previousLocation) {
                sendActions(for: .mouseDragInside, with: event)
            } else {
                sendActions(for: .mouseDragEnter, with: event)
            }
        } else {
            isHighlighted = false

            if point(inside: previousLocation) {
                sendActions(for: .mouseDragExit, with: event)
            } else {
                sendActions(for: .mouseDragOutside, with: event)
            }
        }
    }

    open override func mouseUp(with event: Event) {
        let location = convert(event.locationInWindow, from: window)

        if point(inside: location) {
            sendActions(for: .mouseUpInside, with: event)
        } else {
            sendActions(for: .mouseUpOutside, with: event)
        }

        lastLocationsForMouseButton.removeValue(forKey: event.buttonNumber)

        isHighlighted = false
    }

    open override func rightMouseDown(with event: Event) {
        lastLocationsForMouseButton[event.buttonNumber] = convert(event.locationInWindow, from: window)

        sendActions(for: .rightMouseDown, with: event)
    }

    open override func rightMouseDragged(with event: Event) {
        let location = convert(event.locationInWindow, from: window)

        let previousLocation = lastLocationsForMouseButton[event.buttonNumber] ?? CGPoint(x: CGFloat.nan, y: CGFloat.nan)
        lastLocationsForMouseButton[event.buttonNumber] = location

        if point(inside: location) {
            if point(inside: previousLocation) {
                sendActions(for: .rightMouseDragInside, with: event)
            } else {
                sendActions(for: .rightMouseDragEnter, with: event)
            }
        } else {
            if point(inside: previousLocation) {
                sendActions(for: .rightMouseDragExit, with: event)
            } else {
                sendActions(for: .rightMouseDragOutside, with: event)
            }
        }
    }

    open override func rightMouseUp(with event: Event) {
        let location = convert(event.locationInWindow, from: window)

        if point(inside: location) {
            sendActions(for: .rightMouseUpInside, with: event)
        } else {
            sendActions(for: .rightMouseUpOutside, with: event)
        }

        lastLocationsForMouseButton.removeValue(forKey: event.buttonNumber)
    }

    open override func otherMouseDown(with event: Event) {
        lastLocationsForMouseButton[event.buttonNumber] = convert(event.locationInWindow, from: window)

        sendActions(for: .otherMouseDown, with: event)
    }

    open override func otherMouseDragged(with event: Event) {
        let location = convert(event.locationInWindow, from: window)

        let previousLocation = lastLocationsForMouseButton[event.buttonNumber] ?? CGPoint(x: CGFloat.nan, y: CGFloat.nan)
        lastLocationsForMouseButton[event.buttonNumber] = location

        if point(inside: location) {
            if point(inside: previousLocation) {
                sendActions(for: .otherMouseDragInside, with: event)
            } else {
                sendActions(for: .otherMouseDragEnter, with: event)
            }
        } else {
            if point(inside: previousLocation) {
                sendActions(for: .otherMouseDragExit, with: event)
            } else {
                sendActions(for: .otherMouseDragOutside, with: event)
            }
        }
    }

    open override func otherMouseUp(with event: Event) {
        let location = convert(event.locationInWindow, from: window)

        if point(inside: location) {
            sendActions(for: .otherMouseUpInside, with: event)
        } else {
            sendActions(for: .otherMouseUpOutside, with: event)
        }

        lastLocationsForMouseButton.removeValue(forKey: event.buttonNumber)
    }

    // MARK: Mouse Tracking

    open func startTrackingMouse(with event: Event) -> Bool {
        return false
    }

    open func continueTrackingMouse(with event: Event) -> Bool {
        return false
    }

    open func stopTrackingMouse(with event: Event) {
    }

    // MARK: Actions
    public var actions: Set<ActionIdentifier> = []
}

public extension Control {
    struct State: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static var normal = State([])
        public static var highlighted = State(rawValue: 1 << 0)
        public static var disabled = State(rawValue: 1 << 1)
        public static var selected = State(rawValue: 1 << 2)
        public static var focused = State(rawValue: 1 << 3)
        public static var application = State(rawValue: 1 << 4)
    }
}

public extension Control {
    struct ControlEvent : OptionSet {
        public typealias RawValue = UInt64
        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static var mouseDown = ControlEvent(rawValue: 1 << 1)
        public static var mouseDownRepeat = ControlEvent(rawValue: 1 << 2)
        public static var mouseDragInside = ControlEvent(rawValue: 1 << 3)
        public static var mouseDragOutside = ControlEvent(rawValue: 1 << 4)
        public static var mouseDragEnter = ControlEvent(rawValue: 1 << 5)
        public static var mouseDragExit = ControlEvent(rawValue: 1 << 6)
        public static var mouseUpInside = ControlEvent(rawValue: 1 << 7)
        public static var mouseUpOutside = ControlEvent(rawValue: 1 << 8)
        public static var mouseCancel = ControlEvent(rawValue: 1 << 9)

        public static var rightMouseDown = ControlEvent(rawValue: 1 << 10)
        public static var rightMouseDownRepeat = ControlEvent(rawValue: 1 << 11)
        public static var rightMouseDragInside = ControlEvent(rawValue: 1 << 12)
        public static var rightMouseDragOutside = ControlEvent(rawValue: 1 << 13)
        public static var rightMouseDragEnter = ControlEvent(rawValue: 1 << 14)
        public static var rightMouseDragExit = ControlEvent(rawValue: 1 << 15)
        public static var rightMouseUpInside = ControlEvent(rawValue: 1 << 16)
        public static var rightMouseUpOutside = ControlEvent(rawValue: 1 << 17)
        public static var rightMouseCancel = ControlEvent(rawValue: 1 << 18)

        public static var otherMouseDown = ControlEvent(rawValue: 1 << 19)
        public static var otherMouseDownRepeat = ControlEvent(rawValue: 1 << 20)
        public static var otherMouseDragInside = ControlEvent(rawValue: 1 << 21)
        public static var otherMouseDragOutside = ControlEvent(rawValue: 1 << 22)
        public static var otherMouseDragEnter = ControlEvent(rawValue: 1 << 23)
        public static var otherMouseDragExit = ControlEvent(rawValue: 1 << 24)
        public static var otherMouseUpInside = ControlEvent(rawValue: 1 << 25)
        public static var otherMouseUpOutside = ControlEvent(rawValue: 1 << 26)
        public static var otherMouseCancel = ControlEvent(rawValue: 1 << 27)

        public static var valueChanged = ControlEvent(rawValue: 1 << 28)
        public static var primaryActionTriggered = ControlEvent(rawValue: 1 << 29)
        public static var editingDidBegin = ControlEvent(rawValue: 1 << 30)
        public static var editingChanged = ControlEvent(rawValue: 1 << 31)
        public static var editingDidEnd = ControlEvent(rawValue: 1 << 32)
        public static var editingDidEndOnExit = ControlEvent(rawValue: 1 << 33)

        public static var applicationReserved = ControlEvent(rawValue: 1 << 36)
        public static var systemReserved = ControlEvent(rawValue: 1 << 37)

        public static var allEvents = ControlEvent(rawValue: RawValue.max)
    }
}
