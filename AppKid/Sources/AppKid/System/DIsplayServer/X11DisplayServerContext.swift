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
    var deleteWindowAtom = Atom(None)
    var takeFocusAtom = Atom(None)
    var xiTouchPadAtom = Atom(None)
    var xiMouseAtom = Atom(None)
    var xiKeyvoardAtom = Atom(None)
    var syncRequestAtom = Atom(None)
    var stayAboveAtom = Atom(None)
    var stayBelowAtom = Atom(None)
    var stateAtom = Atom(None)

    var currentPressedMouseButton: XInput2Button = .none
    var currentModifierFlags: Event.ModifierFlags = .none

    var inputDevices: [XInput2Device] = []
}
