//
//  X11Context.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.04.2020.
//

import Foundation

import CX11.Xlib
import CX11.X
import CXInput2

#if os(Linux)
import CEpoll
import Glibc
#endif

internal struct X11Context {
    internal var displayConnectionFileDescriptor: CInt = -1
    internal var epollFileDescriptor: CInt = -1
    internal var eventFileDescriptor: CInt = -1

    internal var xInput2ExtensionOpcode: CInt = 0
    internal var wmDeleteWindowAtom: CX11.Atom = CUnsignedLong(CX11.None)
}
