//
//  Responder.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import Foundation

open class Responder {
    public internal(set) weak var nextResponder: Responder? = nil
    public fileprivate(set) var acceptsFirstResponder = true
    
    open func mouseDown(with event: Event) {}
    open func rightMouseDown(with event: Event) {}
    open func otherMouseDown(with event: Event) {}
    open func mouseUp(with event: Event) {}
    open func rightMouseUp(with event: Event) {}
    open func otherMouseUp(with event: Event) {}
    open func mouseMoved(with event: Event) {}
    open func mouseDragged(with event: Event) {}
    open func rightMouseDragged(with event: Event) {}
    open func otherMouseDragged(with event: Event) {}
    open func scrollWheel(with event: Event) {}
    open func mouseEntered(with event: Event) {}
    open func mouseExited(with event: Event) {}
    open func keyDown(with event: Event) {}
    open func keyUp(with event: Event) {}
    open func flagsChanged(with event: Event) {}

    open var canBecomeFirstResponder: Bool { return false }
    open func becomeFirstResponder() -> Bool { return false }
    open var canResignFirstResponder: Bool { return false }
    open func resignFirstResponder() -> Bool { return false }
    open var isFirstResponder: Bool { return false }
}

internal extension Responder {
    static var mouseEventTypeToHandler: [Event.EventType: (Responder) -> (_ event: Event) -> ()] = [
        .leftMouseDown: Responder.mouseDown,
        .rightMouseDown: Responder.rightMouseDown,
        .otherMouseDown: Responder.otherMouseDown,
        .leftMouseUp: Responder.mouseUp,
        .rightMouseUp: Responder.rightMouseUp,
        .otherMouseUp: Responder.otherMouseUp,
        .mouseMoved: Responder.mouseMoved,
        .leftMouseDragged: Responder.mouseDragged,
        .rightMouseDragged: Responder.rightMouseDragged,
        .otherMouseDragged: Responder.otherMouseDragged,
        .scrollWheel: Responder.scrollWheel,
        .mouseEntered: Responder.mouseEntered,
        .mouseExited: Responder.mouseExited,
    ]
}
