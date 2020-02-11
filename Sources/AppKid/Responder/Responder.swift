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
    
    public init() {}
    
    open func mouseDown(with event: Event) {}
    open func rightMouseDown(with event: Event) {}
    open func otherMouseDown(with event: Event) {}
    open func mouseUp(with event: Event) {}
    open func rightMouseUp(with event: Event) {}
    open func otherMouseUp(with event: Event) {}
    open func mouseMoved(with event: Event) {}
    open func mouseDragged(with event: Event) {}
    open func scrollWheel(with event: Event) {}
    open func rightMouseDragged(with event: Event) {}
    open func otherMouseDragged(with event: Event) {}
    open func mouseEntered(with event: Event) {}
    open func mouseExited(with event: Event) {}
    open func keyDown(with event: Event) {}
    open func keyUp(with event: Event) {}
    open func flagsChanged(with event: Event) {}
    
    open func becomeFirstResponder() -> Bool { return false }
    open func resignFirstResponder() -> Bool { return false }
}