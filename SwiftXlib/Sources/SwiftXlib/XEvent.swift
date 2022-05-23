//
//  XEvent.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 21.05.2022.
//

import Foundation
import TinyFoundation
import CXlib

public protocol XEventProtocol {
    var type: CInt { get }
}

public extension XEventProtocol {
    mutating func withTypeErasedEvent<R>(_ body: (UnsafeMutablePointer<XEvent>
    ) throws -> (R)) rethrows -> R {
        try withUnsafeMutablePointer(to: &self) { event in
            try event.withMemoryRebound(to: XEvent.self, capacity: 1) {
                try body($0)
            }
        }
    }
}

extension XEvent: XEventProtocol {}
extension XAnyEvent: XEventProtocol {}
extension XKeyEvent: XEventProtocol {}
extension XButtonEvent: XEventProtocol {}
extension XMotionEvent: XEventProtocol {}
extension XCrossingEvent: XEventProtocol {}
extension XFocusChangeEvent: XEventProtocol {}
extension XExposeEvent: XEventProtocol {}
extension XGraphicsExposeEvent: XEventProtocol {}
extension XNoExposeEvent: XEventProtocol {}
extension XVisibilityEvent: XEventProtocol {}
extension XCreateWindowEvent: XEventProtocol {}
extension XDestroyWindowEvent: XEventProtocol {}
extension XUnmapEvent: XEventProtocol {}
extension XMapEvent: XEventProtocol {}
extension XMapRequestEvent: XEventProtocol {}
extension XReparentEvent: XEventProtocol {}
extension XConfigureEvent: XEventProtocol {}
extension XGravityEvent: XEventProtocol {}
extension XResizeRequestEvent: XEventProtocol {}
extension XConfigureRequestEvent: XEventProtocol {}
extension XCirculateEvent: XEventProtocol {}
extension XCirculateRequestEvent: XEventProtocol {}
extension XPropertyEvent: XEventProtocol {}
extension XSelectionClearEvent: XEventProtocol {}
extension XSelectionRequestEvent: XEventProtocol {}
extension XSelectionEvent: XEventProtocol {}
extension XColormapEvent: XEventProtocol {}
extension XClientMessageEvent: XEventProtocol {}
extension XMappingEvent: XEventProtocol {}
extension XErrorEvent: XEventProtocol {}
extension XKeymapEvent: XEventProtocol {}
extension XGenericEvent: XEventProtocol {}
extension XGenericEventCookie: XEventProtocol {}
