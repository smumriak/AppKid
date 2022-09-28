//
//  ResponderEditActions.swift
//  AppKid
//  
//  Created by Serhii Mumriak on 17.07.2022
//

public protocol CutResponder {
    func cut(_ sender: Any?)
}

public struct CutResponderAction: ResponderAction {
    public typealias ResponderActionHandler = CutResponder

    public func perform(on responder: ResponderActionHandler, withSender sender: Any?) {
        responder.cut(sender)
    }
}

public protocol CopyResponder {
    func copy(_ sender: Any?)
}

public struct CopyResponderAction: ResponderAction {
    public typealias ResponderActionHandler = CopyResponder

    public func perform(on responder: ResponderActionHandler, withSender sender: Any?) {
        responder.copy(sender)
    }
}

public protocol PasteResponder {
    func paste(_ sender: Any?)
}

public struct PasteResponderAction: ResponderAction {
    public typealias ResponderActionHandler = PasteResponder

    public func perform(on responder: ResponderActionHandler, withSender sender: Any?) {
        responder.paste(sender)
    }
}
