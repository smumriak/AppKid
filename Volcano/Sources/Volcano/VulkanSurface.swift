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

public final class VulkanSurface: VulkanEntity<CustomDestructablePointer<VkSurfaceKHR_T>> {
    public unowned let device: VulkanDevice
    public let queueFamilyIndex: Int
    public let imageFormat: VkFormat
    public let colorSpace: VkColorSpaceKHR
    public let capabilities: VkSurfaceCapabilitiesKHR
    public let presetModes: [VkPresentModeKHR]
    public var size: VkExtent2D

    public init(device: VulkanDevice, display: UnsafeMutablePointer<Display>, window: Window, size: VkExtent2D) throws {
        self.device = device
        self.size = size

        let physicalDevice = device.physicalDevice

        let instance = device.instance

        let surface: VkSurfaceKHR
        #if os(Linux)
        var surfaceCreationInfo: VkXlibSurfaceCreateInfoKHR = VkXlibSurfaceCreateInfoKHR()
        surfaceCreationInfo.sType = VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR
        surfaceCreationInfo.dpy = display
        surfaceCreationInfo.window = window

        surface = try instance.handle.createEntity(info: &surfaceCreationInfo, using: vkCreateXlibSurfaceKHR)
        #elseif os(macOS)
        var surfaceCreationInfo = VkMacOSSurfaceCreateInfoMVK()
        surface = try instance.handle.createEntity(info: &surfaceCreationInfo, using: vkCreateMacOSSurfaceMVK)
        #else
        fatalError("Wrong OS! (For now)")
        #endif

        let queueOffsetPair = try physicalDevice.queueFamiliesProperties.enumerated().first {
            let supportsPresenting = try surface.supportsPresenting(onQueueFamilyIndex: $0.offset, physicalDevice: physicalDevice)

            return ($0.element.queueFlags & VK_QUEUE_GRAPHICS_BIT.rawValue) != 0 && supportsPresenting
        }

        guard let queueFamilyIndex = queueOffsetPair?.offset else {
            fatalError("No queues that support image presenting")
        }

        self.queueFamilyIndex = queueFamilyIndex

        let surfaceFormats = try physicalDevice.loadDataArray(for: surface, using: vkGetPhysicalDeviceSurfaceFormatsKHR)
        guard let surfaceFormat = surfaceFormats.first else {
            fatalError("No surface formates available")
        }

        imageFormat = surfaceFormat.format == VK_FORMAT_UNDEFINED ? VK_FORMAT_B8G8R8A8_UNORM : surfaceFormat.format
        colorSpace = surfaceFormat.colorSpace

        capabilities = try physicalDevice.loadData(for: surface, using: vkGetPhysicalDeviceSurfaceCapabilitiesKHR)
        presetModes = try physicalDevice.loadDataArray(for: surface, using: vkGetPhysicalDeviceSurfacePresentModesKHR)

        let handlePointer = CustomDestructablePointer(with: surface) { [unowned instance] in
            vkDestroySurfaceKHR(instance.handle, $0, nil)
        }

        try super.init(instance: instance, handlePointer: handlePointer)
    }
}

internal extension UnsafeMutablePointer where Pointee == VkSurfaceKHR_T {
    func supportsPresenting(onQueueFamilyIndex queueFamilyIndex: Int, physicalDevice: VulkanPhysicalDevice) throws -> Bool {
        var supportsPresentingVKBool: VkBool32 = VkBool32(VK_FALSE)
        try vulkanInvoke {
            vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice.handle, UInt32(queueFamilyIndex), self, &supportsPresentingVKBool)
        }
        return supportsPresentingVKBool == VkBool32(VK_FALSE) ? false : true
    }
}
