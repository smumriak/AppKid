//
//  Control.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import Foundation

open class Control: View {
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
    }

    open override func mouseDragged(with event: Event) {
    }

    open override func mouseUp(with event: Event) {
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
    public typealias Action = (_ sender: Control) -> ()

    fileprivate var actions: Set<ActionIdentifier> = []

    open func add(action: @escaping Action, for event: ControlEvent) -> some ActionIdentifier {
        let actionIndentifier = ActionIdentifier(action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    open func remove(actionIdentifier: ActionIdentifier, for event: ControlEvent? = nil) {
        guard actions.contains(actionIdentifier) else {
            return
        }

        if let event = event {
            actionIdentifier.event.remove(event)
        } else {
            actionIdentifier.event = []
        }

        if actionIdentifier.event == [] {
            actions.remove(actionIdentifier)
        }
    }

    open func removeAllActions() {
        actions.removeAll()
    }
}

public final class ActionIdentifier {
    fileprivate let action: Control.Action
    fileprivate var event: Control.ControlEvent

    init(action: @escaping Control.Action, event: Control.ControlEvent) {
        self.action = action
        self.event = event
    }
}

extension ActionIdentifier: Equatable {
    public static func == (lhs: ActionIdentifier, rhs: ActionIdentifier) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension ActionIdentifier: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
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

extension Control.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
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
