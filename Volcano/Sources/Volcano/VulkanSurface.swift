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

public final class VulkanSurface: VulkanEntity<SmartPointer<VkSurfaceKHR_T>> {
    public unowned let physicalDevice: VulkanPhysicalDevice
    public let supportedFormats: [VkSurfaceFormatKHR]
    public let selectedFormat: VkSurfaceFormatKHR
    public var imageFormat: VkFormat { return selectedFormat.format }
    public var colorSpace: VkColorSpaceKHR { return selectedFormat.colorSpace }
    public let capabilities: VkSurfaceCapabilitiesKHR
    public let presetModes: [VkPresentModeKHR]

    internal init(physicalDevice: VulkanPhysicalDevice, display: UnsafeMutablePointer<Display>, window: Window) throws {
        self.physicalDevice = physicalDevice

        let instance = physicalDevice.instance

        let handle: VkSurfaceKHR
        #if os(Linux)
        var surfaceCreationInfo: VkXlibSurfaceCreateInfoKHR = VkXlibSurfaceCreateInfoKHR()
        surfaceCreationInfo.sType = VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR
        surfaceCreationInfo.dpy = display
        surfaceCreationInfo.window = window

        handle = try instance.handle.createEntity(info: &surfaceCreationInfo, using: vkCreateXlibSurfaceKHR)
        #elseif os(macOS)
        var surfaceCreationInfo = VkMacOSSurfaceCreateInfoMVK()
        handle = try instance.handle.createEntity(info: &surfaceCreationInfo, using: vkCreateMacOSSurfaceMVK)
        #else
        fatalError("Wrong OS! (For now)")
        #endif

        let supportedFormats = try physicalDevice.loadDataArray(for: handle, using: vkGetPhysicalDeviceSurfaceFormatsKHR)
        if supportedFormats.isEmpty {
            fatalError("No surface formates available")
        }

        let desiredFormat = VkSurfaceFormatKHR(format: VK_FORMAT_B8G8R8A8_UNORM, colorSpace: VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)

        if supportedFormats.contains(desiredFormat) || (supportedFormats.count == 1 && supportedFormats[0].format == VK_FORMAT_UNDEFINED) {
            selectedFormat = desiredFormat
        } else {
            selectedFormat = supportedFormats[0]
        }

        self.supportedFormats = supportedFormats

        capabilities = try physicalDevice.loadData(for: handle, using: vkGetPhysicalDeviceSurfaceCapabilitiesKHR)
        presetModes = try physicalDevice.loadDataArray(for: handle, using: vkGetPhysicalDeviceSurfacePresentModesKHR)

        let handlePointer = SmartPointer(with: handle) { [unowned instance] in
            vkDestroySurfaceKHR(instance.handle, $0, nil)
        }

        try super.init(instance: instance, handlePointer: handlePointer)
    }

    func supportsPresenting(onQueueFamilyIndex queueFamilyIndex: Int) throws -> Bool {
        var supportsPresentingVKBool: VkBool32 = VkBool32(VK_FALSE)
        try vulkanInvoke {
            vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice.handle, UInt32(queueFamilyIndex), handle, &supportsPresentingVKBool)
        }
        return supportsPresentingVKBool == VkBool32(VK_FALSE) ? false : true
    }
}

extension VkSurfaceFormatKHR: Equatable {
    public static func == (lhs: VkSurfaceFormatKHR, rhs: VkSurfaceFormatKHR) -> Bool {
        return lhs.format == rhs.format && lhs.colorSpace == rhs.colorSpace
    }
}
