//
//  ResponderAction.swift
//  AppKid
//
//  Created by Serhii Mumriak on 17.07.2022
//

public protocol ResponderAction<ResponderActionHandler> {
    associatedtype ResponderActionHandler

    func perform(on responder: ResponderActionHandler, withSender sender: Any?)
}

internal extension ResponderAction {
    func canBePeformed(on responder: Responder) -> Bool {
        return responder is ResponderActionHandler
    }

    static func canBePeformed(on responder: Responder) -> Bool {
        return responder is ResponderActionHandler
    }
    
    func performUnsafe(on responder: Responder, withSender sender: Any?) {
        perform(on: responder as! ResponderActionHandler, withSender: sender)
    }

    func findHandlerInResponderChain(_ firstResponder: Responder) -> Responder? {
        var responder: Responder? = firstResponder

        repeat {
            if let responder = responder, canBePeformed(on: responder) {
                return responder
            } else {
                responder = responder?.nextResponder
            }
        } while responder != nil

        return nil
    }
}

public struct ControlResponderAction<Target: AnyObject>: ResponderAction {
    public typealias ResponderActionHandler = Target
    let actionIdentifier: ControlProtocol.ActionIdentifier
    let event: Event

    public func perform(on responder: Target, withSender sender: Any?) {
        let casted = sender! as! ControlProtocol
        actionIdentifier.invoke(sender: casted, event: event)
    }  
}
