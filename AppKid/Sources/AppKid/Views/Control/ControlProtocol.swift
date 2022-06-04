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
    typealias SenderEventAction<Sender> = (_ sender: Sender, _ event: AppKid.Event) -> ()

    typealias ClassAction<Target, Sender> = (Target) -> () -> ()
    typealias SenderClassAction<Target, Sender> = (Target) -> (_ sender: Sender) -> ()
    typealias SenderEventClassAction<Target, Sender> = (Target) -> (_ sender: Sender, _ event: AppKid.Event) -> ()

    var actions: Set<ActionIdentifier> { get set }
}

public extension ControlProtocol {
    @discardableResult
    func addAction(for event: Control.Event, action: @escaping Action<Self>) -> ActionIdentifier {
        let actionIndentifier = PlainActionIdentifier(action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func addAction(for event: Control.Event, action: @escaping SenderAction<Self>) -> ActionIdentifier {
        let actionIndentifier = SenderActionIdentifier(action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func addAction(for event: Control.Event, action: @escaping SenderEventAction<Self>) -> ActionIdentifier {
        let actionIndentifier = SenderEventActionIdentifier(action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func add<Target>(target: Target, action: @escaping ClassAction<Target, Self>, for event: Control.Event) -> ActionIdentifier where Target: AnyObject {
        let actionIndentifier = TargetActionIdentifier(target: target, action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func add<Target>(target: Target, action: @escaping SenderClassAction<Target, Self>, for event: Control.Event) -> ActionIdentifier where Target: AnyObject {
        let actionIndentifier = TargetSenderActionIdentifier(target: target, action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    @discardableResult
    func add<Target>(target: Target, action: @escaping SenderEventClassAction<Target, Self>, for event: Control.Event) -> ActionIdentifier where Target: AnyObject {
        let actionIndentifier = TargetSenderEventActionIdentifier(target: target, action: action, event: event)

        actions.insert(actionIndentifier)

        return actionIndentifier
    }

    func remove(actionIdentifier: ActionIdentifier, for event: Control.Event? = nil) {
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

    func sendActions(for controlEvents: Control.Event, with event: AppKid.Event) {
        actions.forEach {
            if !$0.event.intersection(controlEvents).isEmpty {
                $0.invoke(sender: self, event: event)
            }
        }
    }
}

public extension Control {
    class ActionIdentifier {
        internal var event: Control.Event

        internal init(event: Control.Event) {
            self.event = event
        }

        internal func invoke(sender: ControlProtocol, event: AppKid.Event) {}
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
