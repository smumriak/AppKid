//
//  VulkanRenderStack.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.08.2020.
//

import Foundation
import Volcano
import TinyFoundation
import CVulkan

public final class VulkanRenderStack {
    public fileprivate(set) var instance: Instance
    public fileprivate(set) var physicalDevice: PhysicalDevice
    public fileprivate(set) var device: Device

    public init() throws {
        instance = Instance()

        guard let physicalDevice = instance.discreteGPUDevice else {
            throw VulkanRendererError.noDiscreteGPU
        }

        self.physicalDevice = physicalDevice

        device = try Device(physicalDevice: physicalDevice, queuesRequests: [.default])
    }

    public func createSurface(for window: Window) throws -> Surface {
        #if os(Linux)
            return try physicalDevice.createXlibSurface(display: window.nativeWindow.display, window: window.nativeWindow.windowID)
        #elseif os(macOS)
            fatalError("macOS rendering is not currently supported")
        #elseif os(Windows)
            #error("Wrong OS! (For now)")
        #else
            #error("Wrong OS! (For now)")
        #endif
    }
}
