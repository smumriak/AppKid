//
//  X11DisplayServerContext.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.04.2020.
//

import Foundation

import CX11.Xlib
import CX11.X
import CXInput2

internal struct X11DisplayServerContext {
    var displayConnectionFileDescriptor: CInt = -1

    var scale: CGFloat = 1.0

    var xInput2ExtensionOpcode: CInt = 0
    var deleteWindowAtom = Atom(CX11.None)
    var takeFocusAtom = Atom(CX11.None)
    var xiTouchPadAtom = Atom(CX11.None)
    var xiMouseAtom = Atom(CX11.None)
    var xiKeyvoardAtom = Atom(CX11.None)
    var syncRequestAtom = Atom(CX11.None)

    var currentPressedMouseButton: XInput2Button = .none
    var currentModifierFlags: Event.ModifierFlags = .none

    var inputDevices: [XInput2Device] = []
}
