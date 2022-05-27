//
//  X11DisplayServerContext.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.04.2020.
//

import Foundation

import CXlib
import SwiftXlib

internal struct X11DisplayServerContext {
    var scale: CGFloat = 1.0

    var currentPressedMouseButton: XInput2Button = .none
    var currentModifierFlags: Event.ModifierFlags = .none

    var inputDevices: [XInput2Device] = []
}
