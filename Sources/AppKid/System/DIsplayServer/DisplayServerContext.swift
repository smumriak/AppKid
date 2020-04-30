//
//  DisplayServerContext.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.04.2020.
//

import Foundation

import CX11.Xlib
import CX11.X
import CXInput2


internal struct DisplayServerContext {
    var displayConnectionFileDescriptor: CInt = -1
    var epollFileDescriptor: CInt = -1
    var eventFileDescriptor: CInt = -1

    var scale: CGFloat = 1.0

    var xInput2ExtensionOpcode: CInt = 0
    var wmDeleteWindowAtom: CX11.Atom = CUnsignedLong(CX11.None)

    var currentPressedMouseButton: XInput2Button = .none
    var currentModifierFlags: Event.ModifierFlags = .none
}
