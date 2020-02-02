//
//  Event+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation
import CX11.X
import CX11.Xlib

internal extension EventType {
    static func x11EventMask() -> Int {
        return CX11.ExposureMask | CX11.KeyPressMask
    }
}

internal extension Event {
}
