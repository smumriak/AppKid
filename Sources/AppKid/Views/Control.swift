//
//  Control.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import Foundation

open class Control: View {
    public var isEnabled: Bool {
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

    public var isSelected: Bool {
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

    public var isHighlighted: Bool {
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

    internal(set) public var state: State = .normal {
        didSet {
        }
    }

    public typealias Action = (_ sender: Control) -> ()
    fileprivate var targetWrappers = [ControlInvokable]()

    public func add<TargetType: AnyObject>(target: TargetType?, action: @escaping (TargetType) -> Action) {
        if let target = target {
            let targetWrapper = TargetWrapper(target: target, action: action)
            targetWrappers.append(targetWrapper)
        }
    }
}

fileprivate protocol ControlInvokable {
    func invoke(sender: Control)
}

fileprivate final class TargetWrapper<TargetType: AnyObject> : ControlInvokable {
    weak var target: TargetType?
    let action: (TargetType) -> Control.Action
    
    init(target: TargetType, action: @escaping (TargetType) -> Control.Action) {
        self.target = target
        self.action = action
    }
    
    func invoke(sender: Control) {
        if let target = target {
            action(target)(sender)
        }
    }
}

public extension Control {
    struct State: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static var normal = State(rawValue: 0)
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
