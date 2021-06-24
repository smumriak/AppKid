//
//  VolcanoRenderStack+Surface.swift
//  AppKid
//
//  Created by Serhii Mumriak on 23.08.2020.
//

import ContentAnimation
import Volcano

public extension VolcanoRenderStack {
    func createSurface(for window: Window) throws -> Surface {
        #if os(Linux)
            return try physicalDevice.createXlibSurface(display: window.nativeWindow.display.handle, window: window.nativeWindow.windowID)
        #elseif os(macOS)
            fatalError("macOS rendering is not currently supported")
        #elseif os(Windows)
            #error("Wrong OS! (For now)")
        #else
            #error("Wrong OS! (For now)")
        #endif
    }
}
