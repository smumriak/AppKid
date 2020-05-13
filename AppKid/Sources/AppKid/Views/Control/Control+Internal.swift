//
//  Control+Internal.swift
//  AppKid
//
//  Created by Serhii Mumriak on 23.04.2020.
//

import Foundation

internal class PlainActionIdentifier: Control.ActionIdentifier {
    public typealias Action = () -> ()

    internal let action: Action

    init(action: @escaping Action, event: Control.ControlEvent) {
        self.action = action

        super.init(event: event)
    }

    internal override func invoke(sender: ControlProtocol, event: Event) {
        action()
    }
}

internal class SenderActionIdentifier<Sender>: Control.ActionIdentifier {
    public typealias Action = (_ sender: Sender) -> ()

    internal let action: Action

    init(action: @escaping Action, event: Control.ControlEvent) {
        self.action = action

        super.init(event: event)
    }

    internal override func invoke(sender: ControlProtocol, event: Event) {
        action(sender as! Sender)
    }
}

internal class SenderEventActionIdentifier<Sender>: Control.ActionIdentifier {
    public typealias Action = (_ sender: Sender, _ event: Event) -> ()

    internal let action: Action

    init(action: @escaping Action, event: Control.ControlEvent) {
        self.action = action

        super.init(event: event)
    }

    internal override func invoke(sender: ControlProtocol, event: Event) {
        action(sender as! Sender, event)
    }
}

internal class TargetActionIdentifier<Target>: Control.ActionIdentifier where Target: AnyObject {
    public typealias Action = (Target) -> () -> ()

    internal weak var target: Target? = nil
    internal let action: Action

    init(target: Target, action: @escaping Action, event: Control.ControlEvent) {
        self.target = target
        self.action = action

        super.init(event: event)
    }

    internal override func invoke(sender: ControlProtocol, event: Event) {
        target.map { action($0)() }
    }
}

internal class TargetSenderActionIdentifier<Target, Sender>: Control.ActionIdentifier where Target: AnyObject {
    public typealias Action = (Target) -> (_ sender: Sender) -> ()

    internal weak var target: Target? = nil
    internal let action: Action

    init(target: Target, action: @escaping Action, event: Control.ControlEvent) {
        self.target = target
        self.action = action

        super.init(event: event)
    }

    internal override func invoke(sender: ControlProtocol, event: Event) {
        target.map { action($0)(sender as! Sender) }
    }
}

internal class TargetSenderEventActionIdentifier<Target, Sender>: Control.ActionIdentifier where Target: AnyObject {
    public typealias Action = (Target) -> (_ sender: Sender, _ event: Event) -> ()

    internal weak var target: Target? = nil
    internal let action: Action

    init(target: Target, action: @escaping Action, event: Control.ControlEvent) {
        self.target = target
        self.action = action

        super.init(event: event)
    }

    internal override func invoke(sender: ControlProtocol, event: Event) {
        target.map { action($0)(sender as! Sender, event) }
    }
}
