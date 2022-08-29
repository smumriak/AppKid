//
//  Responder.swift
//  AppKid
//
//  Created by Serhii Mumriak on 07.02.2020.
//

import Foundation

open class Responder {
    open var nextResponder: Responder? { return nil }

    internal func responderWindow() -> Window? { return nil }

    open func mouseDown(with event: Event) {
        nextResponder?.mouseDown(with: event)
    }

    open func rightMouseDown(with event: Event) {
        nextResponder?.rightMouseDown(with: event)
    }

    open func otherMouseDown(with event: Event) {
        nextResponder?.otherMouseDown(with: event)
    }

    open func mouseUp(with event: Event) {
        nextResponder?.mouseUp(with: event)
    }

    open func rightMouseUp(with event: Event) {
        nextResponder?.rightMouseUp(with: event)
    }

    open func otherMouseUp(with event: Event) {
        nextResponder?.otherMouseUp(with: event)
    }

    open func mouseMoved(with event: Event) {
        nextResponder?.mouseMoved(with: event)
    }

    open func mouseDragged(with event: Event) {
        nextResponder?.mouseDragged(with: event)
    }

    open func rightMouseDragged(with event: Event) {
        nextResponder?.rightMouseDragged(with: event)
    }

    open func otherMouseDragged(with event: Event) {
        nextResponder?.otherMouseDragged(with: event)
    }

    open func scrollWheel(with event: Event) {
        nextResponder?.scrollWheel(with: event)
    }

    open func mouseEntered(with event: Event) {
        nextResponder?.mouseEntered(with: event)
    }

    open func mouseExited(with event: Event) {
        nextResponder?.mouseExited(with: event)
    }

    open func keyDown(with event: Event) {
        nextResponder?.keyDown(with: event)
    }

    open func keyUp(with event: Event) {
        nextResponder?.keyUp(with: event)
    }

    open func flagsChanged(with event: Event) {
        nextResponder?.flagsChanged(with: event)
    }

    open var canBecomeFirstResponder: Bool { return false }
    open var canResignFirstResponder: Bool { return true }

    @discardableResult
    open func becomeFirstResponder() -> Bool {
        if canBecomeFirstResponder {
            responderWindow()?.firstResponder?.resignFirstResponder()
            responderWindow()?.firstResponder = self

            return true
        } else {
            return false
        }
    }

    @discardableResult
    open func resignFirstResponder() -> Bool {
        if canResignFirstResponder {
            if responderWindow()?.firstResponder === self {
                responderWindow()?.firstResponder = nil

                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    open var isFirstResponder: Bool {
        return responderWindow()?.firstResponder === self
    }
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

extension Responder: Equatable {
    public static func == (lhs: Responder, rhs: Responder) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
