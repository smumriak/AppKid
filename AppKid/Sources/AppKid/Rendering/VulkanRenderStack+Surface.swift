//
//  VolcanoRenderStack+Surface.swift
//  AppKid
//
//  Created by Serhii Mumriak on 23.08.2020.
//

@_spi(AppKid) import ContentAnimation
import Volcano

public extension VolcanoRenderStack {
    func createSurface(for window: Window) throws -> Surface {
        #if os(Linux)
            return try physicalDevice.createXlibSurface(display: window.nativeWindow.display.pointer, window: window.nativeWindow.windowIdentifier)
        #elseif os(macOS)
            fatalError("macOS rendering is not supported and probably never will be. Use AppKit or Catalyst")
        #elseif os(Windows)
            #error("Wrong OS! (For now)")
        #else
            #error("Wrong OS! (For now)")
        #endif
    }
}
