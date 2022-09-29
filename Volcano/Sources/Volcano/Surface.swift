//
//  Surface.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan
import CXlib

public final class Surface: InstanceEntity<SharedPointer<VkSurfaceKHR_T>> {
    public let physicalDevice: PhysicalDevice
    public let supportedFormats: [VkSurfaceFormatKHR]
    public let selectedFormat: VkSurfaceFormatKHR
    public var imageFormat: VkFormat { return selectedFormat.format }
    public var colorSpace: VkColorSpaceKHR { return selectedFormat.colorSpace }
    public internal(set) var capabilities: VkSurfaceCapabilitiesKHR
    public internal(set) var capabilities2: VkSurfaceCapabilities2KHR
    public let presetModes: [VkPresentModeKHR]

    #if os(Linux)
        internal convenience init(physicalDevice: PhysicalDevice, display: UnsafeMutablePointer<Display>, window: Window, desiredFormat: VkSurfaceFormatKHR) throws {
            var info = VkXlibSurfaceCreateInfoKHR.new()
            info.dpy = display
            info.window = window

            let handlePointer = try physicalDevice.instance.create(with: &info)

            try self.init(physicalDevice: physicalDevice, handlePointer: handlePointer, desiredFormat: desiredFormat)
        }

    #elseif os(macOS)
        internal convenience init(physicalDevice: PhysicalDevice, desiredFormat: VkSurfaceFormatKHR) throws {
            var info = VkMacOSSurfaceCreateInfoMVK.new()

            let handlePointer = try physicalDevice.instance.create(with: &info)

            try self.init(physicalDevice: physicalDevice, handlePointer: handlePointer, desiredFormat: desiredFormat)
        }

    #elseif os(Windows)
        #error("Wrong OS! (For now)")
    #else
        #error("Wrong OS! (For now)")
    #endif

    private init(physicalDevice: PhysicalDevice, handlePointer: SharedPointer<VkSurfaceKHR_T>, desiredFormat: VkSurfaceFormatKHR) throws {
        self.physicalDevice = physicalDevice

        let supportedFormats = try physicalDevice.loadDataArray(for: handlePointer.pointer, using: vkGetPhysicalDeviceSurfaceFormatsKHR)
        if supportedFormats.isEmpty {
            fatalError("No surface formates available")
        }

        let desiredFormat = VkSurfaceFormatKHR(format: .b8g8r8a8SRGB, colorSpace: .srgbNonlinear)

        if supportedFormats.contains(desiredFormat) || (supportedFormats.count == 1 && supportedFormats[0].format == .undefined) {
            selectedFormat = desiredFormat
        } else {
            selectedFormat = supportedFormats[0]
        }

        self.supportedFormats = supportedFormats
        
        var surfaceInfo: VkPhysicalDeviceSurfaceInfo2KHR = .new()
        surfaceInfo.surface = handlePointer.pointer

        capabilities2 = try physicalDevice.loadData(with: &surfaceInfo, using: physicalDevice.instance.vkGetPhysicalDeviceSurfaceCapabilities2KHR)
        capabilities = capabilities2.surfaceCapabilities

        presetModes = try physicalDevice.loadDataArray(for: handlePointer.pointer, using: physicalDevice.instance.vkGetPhysicalDeviceSurfacePresentModesKHR)

        try super.init(instance: physicalDevice.instance, handlePointer: handlePointer)
    }

    func supportsPresenting(onQueueFamilyIndex queueFamilyIndex: Int) throws -> Bool {
        var supportsPresentingVKBool: VkBool32 = false.vkBool
        try vulkanInvoke {
            physicalDevice.instance.vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice.handle, UInt32(queueFamilyIndex), handle, &supportsPresentingVKBool)
        }
        return supportsPresentingVKBool.bool
    }

    public func supportsPresenting(on queue: Queue) throws -> Bool {
        guard queue.type.contains(.graphics) else {
            return false
        }

        var supportsPresentingVKBool: VkBool32 = false.vkBool
        try vulkanInvoke {
            physicalDevice.instance.vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice.handle, UInt32(queue.familyIndex), handle, &supportsPresentingVKBool)
        }
        return supportsPresentingVKBool.bool
    }

    public func refreshCapabilities() throws {
        var surfaceInfo: VkPhysicalDeviceSurfaceInfo2KHR = .new()
        surfaceInfo.surface = handlePointer.pointer
        
        capabilities2 = try physicalDevice.loadData(with: &surfaceInfo, using: physicalDevice.instance.vkGetPhysicalDeviceSurfaceCapabilities2KHR)
        capabilities = capabilities2.surfaceCapabilities
    }
}

extension VkSurfaceFormatKHR: Equatable {
    public static func == (lhs: VkSurfaceFormatKHR, rhs: VkSurfaceFormatKHR) -> Bool {
        return lhs.format == rhs.format && lhs.colorSpace == rhs.colorSpace
    }
}
