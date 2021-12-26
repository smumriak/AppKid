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

    open internal(set) var state: State = .normal

    // MARK: - Mouse Events

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

    // MARK: - Mouse Tracking

    open func startTrackingMouse(with event: Event) -> Bool {
        return false
    }

    open func continueTrackingMouse(with event: Event) -> Bool {
        return false
    }

    open func stopTrackingMouse(with event: Event) {
    }

    // MARK: - Actions

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
    struct ControlEvent: OptionSet {
        public typealias RawValue = UInt64
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static var mouseDown = Self(rawValue: 1 << 1)
        public static var mouseDownRepeat = Self(rawValue: 1 << 2)
        public static var mouseDragInside = Self(rawValue: 1 << 3)
        public static var mouseDragOutside = Self(rawValue: 1 << 4)
        public static var mouseDragEnter = Self(rawValue: 1 << 5)
        public static var mouseDragExit = Self(rawValue: 1 << 6)
        public static var mouseUpInside = Self(rawValue: 1 << 7)
        public static var mouseUpOutside = Self(rawValue: 1 << 8)
        public static var mouseCancel = Self(rawValue: 1 << 9)

        public static var rightMouseDown = Self(rawValue: 1 << 10)
        public static var rightMouseDownRepeat = Self(rawValue: 1 << 11)
        public static var rightMouseDragInside = Self(rawValue: 1 << 12)
        public static var rightMouseDragOutside = Self(rawValue: 1 << 13)
        public static var rightMouseDragEnter = Self(rawValue: 1 << 14)
        public static var rightMouseDragExit = Self(rawValue: 1 << 15)
        public static var rightMouseUpInside = Self(rawValue: 1 << 16)
        public static var rightMouseUpOutside = Self(rawValue: 1 << 17)
        public static var rightMouseCancel = Self(rawValue: 1 << 18)

        public static var otherMouseDown = Self(rawValue: 1 << 19)
        public static var otherMouseDownRepeat = Self(rawValue: 1 << 20)
        public static var otherMouseDragInside = Self(rawValue: 1 << 21)
        public static var otherMouseDragOutside = Self(rawValue: 1 << 22)
        public static var otherMouseDragEnter = Self(rawValue: 1 << 23)
        public static var otherMouseDragExit = Self(rawValue: 1 << 24)
        public static var otherMouseUpInside = Self(rawValue: 1 << 25)
        public static var otherMouseUpOutside = Self(rawValue: 1 << 26)
        public static var otherMouseCancel = Self(rawValue: 1 << 27)

        public static var valueChanged = Self(rawValue: 1 << 28)
        public static var primaryActionTriggered = Self(rawValue: 1 << 29)
        public static var editingDidBegin = Self(rawValue: 1 << 30)
        public static var editingChanged = Self(rawValue: 1 << 31)
        public static var editingDidEnd = Self(rawValue: 1 << 32)
        public static var editingDidEndOnExit = Self(rawValue: 1 << 33)

        public static var applicationReserved = Self(rawValue: 1 << 36)
        public static var systemReserved = Self(rawValue: 1 << 37)

        public static var allEvents = Self(rawValue: RawValue.max)
    }
}
