//
//  VulkanSurface.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan
import CX11.Xlib
import CX11.X

public final class VulkanSurface: VulkanEntity<SimplePointer<VkSurfaceKHR_T>> {
    public unowned let device: VulkanDevice
    public let imageFormat: VkFormat
    public let colorSpace: VkColorSpaceKHR

    deinit {
        vkDestroySurfaceKHR(instance.handle, handle, nil)
    }

    public init(device: VulkanDevice, display: UnsafeMutablePointer<Display>, window: Window) throws {
        self.device = device

        let instance = device.instance

        var surfaceCreationInfo: VkXlibSurfaceCreateInfoKHR = VkXlibSurfaceCreateInfoKHR()
        surfaceCreationInfo.sType = VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR
        surfaceCreationInfo.dpy = display
        surfaceCreationInfo.window = window

        var surfaceOptional: VkSurfaceKHR?
        #if os(Linux)
        try vulkanInvoke {
            vkCreateXlibSurfaceKHR(instance.handle, &surfaceCreationInfo, nil, &surfaceOptional)
        }
        #endif
        let handlePointer = SimplePointer(with: surfaceOptional!)

        var queueCount: CUnsignedInt = 0
        vkGetPhysicalDeviceQueueFamilyProperties(device.physicalDevice.handle, &queueCount, nil)

        var queueFamiltyPropertiesPointer = UnsafeMutablePointer<VkQueueFamilyProperties>.allocate(capacity: Int(queueCount))
        defer { queueFamiltyPropertiesPointer.deallocate() }

        vkGetPhysicalDeviceQueueFamilyProperties(device.physicalDevice.handle, &queueCount, queueFamiltyPropertiesPointer)

        let queuePair = try UnsafeBufferPointer(start: queueFamiltyPropertiesPointer, count: Int(queueCount))
            .enumerated()
            .first { pair in
                var supportsPresentingVKBool: VkBool32 = VkBool32(VK_FALSE)
                try vulkanInvoke {
                    instance.getPhysicalDeviceSurfaceSupportKHR(device.physicalDevice.handle, UInt32(pair.offset), handlePointer.pointer, &supportsPresentingVKBool)
                }
                let supportsPresenting = supportsPresentingVKBool == VkBool32(VK_FALSE) ? false : true

                return (pair.element.queueFlags & VK_QUEUE_GRAPHICS_BIT.rawValue) != 0 && supportsPresenting
        }

        guard let queueIndex = queuePair?.offset else {
            fatalError("No queues that support image presenting")
        }

        var surfaceFormatCount: CUnsignedInt = 0;
        try vulkanInvoke {
            instance.getPhysicalDeviceSurfaceFormatsKHR(device.physicalDevice.handle, handlePointer.pointer, &surfaceFormatCount, nil)
        }

        var surfaceFormatsPointer = UnsafeMutablePointer<VkSurfaceFormatKHR>.allocate(capacity: Int(surfaceFormatCount))
        defer { surfaceFormatsPointer.deallocate() }

        try vulkanInvoke {
            instance.getPhysicalDeviceSurfaceFormatsKHR(device.physicalDevice.handle, handlePointer.pointer, &surfaceFormatCount, surfaceFormatsPointer)
        }

        guard let surfaceFormat = UnsafeBufferPointer(start: surfaceFormatsPointer, count: Int(surfaceFormatCount)).first else {
            fatalError("No surface formates available")
        }

        imageFormat = surfaceFormat.format == VK_FORMAT_UNDEFINED ? VK_FORMAT_B8G8R8A8_UNORM : surfaceFormat.format
        colorSpace = surfaceFormat.colorSpace

        try super.init(instance: instance, handlePointer: handlePointer)
    }
}
