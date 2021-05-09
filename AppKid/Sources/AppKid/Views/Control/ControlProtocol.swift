//
//  ControlProtocol.swift
//  AppKid
//
//  Created by Serhii Mumriak on 23.04.2020.
//

import Foundation

public protocol ControlProtocol: AnyObject {
    typealias ActionIdentifier = Control.ActionIdentifier

    typealias Action<Sender> = () -> ()
    typealias SenderAction<Sender> = (_ sender: Sender) -> ()
    typealias SenderEventAction<Sender> = (_ sender: Sender, _ event: Event) -> ()

    typealias ClassAction<Target, Sender> = (Target) -> () -> ()
    typealias SenderClassAction<Target, Sender> = (Target) -> (_ sender: Sender) -> ()
    typealias SenderEventClassAction<Target, Sender> = (Target) -> (_ sender: Sender, _ event: Event) -> ()

    var actions: Set<ActionIdentifier> { get set }
}

public extension ControlProtocol {
    @discardableResult
    func addAction(for event: Control.ControlEvent, action: @escaping Action<Self>) -> ActionIdentifier {
        let actionIndentifier = PlainActionIdentifier(action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func addAction(for event: Control.ControlEvent, action: @escaping SenderAction<Self>) -> ActionIdentifier {
        let actionIndentifier = SenderActionIdentifier(action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func addAction(for event: Control.ControlEvent, action: @escaping SenderEventAction<Self>) -> ActionIdentifier {
        let actionIndentifier = SenderEventActionIdentifier(action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func add<Target>(target: Target, action: @escaping ClassAction<Target, Self>, for event: Control.ControlEvent) -> ActionIdentifier where Target: AnyObject {
        let actionIndentifier = TargetActionIdentifier(target: target, action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func add<Target>(target: Target, action: @escaping SenderClassAction<Target, Self>, for event: Control.ControlEvent) -> ActionIdentifier where Target: AnyObject {
        let actionIndentifier = TargetSenderActionIdentifier(target: target, action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func add<Target>(target: Target, action: @escaping SenderEventClassAction<Target, Self>, for event: Control.ControlEvent) -> ActionIdentifier where Target: AnyObject {
        let actionIndentifier = TargetSenderEventActionIdentifier(target: target, action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    func remove(actionIdentifier: ActionIdentifier, for event: Control.ControlEvent? = nil) {
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

    func removeAllActions() {
        actions.removeAll()
    }

    func sendActions(for controlEvents: Control.ControlEvent, with event: Event) {
        actions.forEach {
            if !$0.event.intersection(controlEvents).isEmpty {
                $0.invoke(sender: self, event: event)
            }
        }
    }
}

public extension Control {
    class ActionIdentifier {
        internal var event: Control.ControlEvent

        internal init(event: Control.ControlEvent) {
            self.event = event
        }

        internal func invoke(sender: ControlProtocol, event: Event) {}
    }
}

extension Control.ActionIdentifier: Equatable, Hashable {
    public static func == (lhs: Control.ActionIdentifier, rhs: Control.ActionIdentifier) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Control.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
