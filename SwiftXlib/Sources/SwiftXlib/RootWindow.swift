//
//  RootWindow.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 02.04.2021.
//

import Foundation
import TinyFoundation
import CXlib

public class RootWindow: WindowProtocol {
    public unowned let display: Display
    public unowned let screen: Screen
    public let rootWindow: RootWindow? = nil
    public let windowIdentifier: CXlib.Window
    public let destroyOnDeinit: Bool = false

    public lazy var hints: [CXlib.Atom] = get(property: display.knownAtom(.supportedHints), type: XA_ATOM)

    public lazy var supportsExtendedSyncCounter: Bool = hints.contains(display.knownAtom(.frameDrawn))

    @_spi(AppKid) public init(display: Display, screen: Screen) {
        self.display = display
        self.screen = screen
        self.windowIdentifier = XDefaultRootWindow(display.pointer)
    }
}
