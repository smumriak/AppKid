//
//  RootWindow.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 02.04.2021.
//

import Foundation
import TinyFoundation
import CXlib

public class RootWindow: Window {
    public lazy var hints: [Atom] = get(property: display.supportedHintsAtom, type: XA_ATOM)

    public lazy var supportsExtendedSyncCounter: Bool = hints.contains(display.frameDrawnAtom)

    public init(display: Display, screen: Screen) {
        super.init(display: display, screen: screen, rootWindow: nil, windowIdentifier: XDefaultRootWindow(display.handle), destroyOnDeinit: false)
    }
}
