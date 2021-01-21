//
//  Window.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation
import TinyFoundation
import CXlib

public final class Window: NSObject {
    public let display: Display
    public let screen: Screen
    public let rootWindow: Window?
    public let windowID: CXlib.Window
    public let destroyOnDeinit: Bool
    
    deinit {
        if destroyOnDeinit {
            XDestroyWindow(display.handle, windowID)
        }
    }

    public init(display: Display, screen: Screen, rootWindow: Window? = nil, windowID: CXlib.Window, destroyOnDeinit: Bool = true) {
        self.display = display
        self.screen = screen
        self.rootWindow = rootWindow
        self.windowID = windowID
        self.destroyOnDeinit = false

        super.init()
    }

    // public convenience init(rootWindow: Window, )
}

public extension Rect where StorageType == CInt {
    init(x11WindowAttributes windowAttributes: XWindowAttributes) {
        self.init(x: windowAttributes.x, y: windowAttributes.y, width: windowAttributes.width, height: windowAttributes.height)
    }
}
