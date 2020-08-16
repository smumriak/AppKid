//
//  Swapchain.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class Swapchain: VulkanDeviceEntity<SmartPointer<VkSwapchainKHR_T>> {
    public unowned let surface: Surface
    public var size: VkExtent2D
    public let imageFormat: VkFormat

    public init(device: Device, surface: Surface, size: VkExtent2D, usage: VkImageUsageFlagBits, compositeAlpha: VkCompositeAlphaFlagBitsKHR = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR) throws {
        self.surface = surface
        self.size = size
        self.imageFormat = surface.imageFormat

        let capabilities = surface.capabilities

        let presentMode: VkPresentModeKHR
        if surface.presetModes.contains(VK_PRESENT_MODE_MAILBOX_KHR) {
            presentMode = VK_PRESENT_MODE_MAILBOX_KHR
        } else {
            presentMode = VK_PRESENT_MODE_FIFO_KHR
        }

        let imageCount = min(capabilities.minImageCount + 1, capabilities.maxImageCount)

        var info = VkSwapchainCreateInfoKHR()
        info.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        info.surface = surface.handle
        info.minImageCount = imageCount
        info.imageFormat = surface.imageFormat
        info.imageColorSpace = surface.colorSpace
        info.imageExtent = size
        info.imageArrayLayers = 1
        info.imageUsage = usage.rawValue
        info.preTransform = surface.capabilities.currentTransform
        info.compositeAlpha = compositeAlpha
        info.presentMode = presentMode

        let queueFamiliesIndices = SmartPointer<CUnsignedInt>.allocate(capacity: 2)
        queueFamiliesIndices.pointer[0] = CUnsignedInt(device.graphicsQueueFamilyIndex)
        queueFamiliesIndices.pointer[1] = CUnsignedInt(device.presentationQueueFamilyIndex)

        if device.graphicsQueueFamilyIndex == device.presentationQueueFamilyIndex {
            info.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
            info.queueFamilyIndexCount = 0
            info.pQueueFamilyIndices = nil
        } else {
            info.imageSharingMode = VK_SHARING_MODE_CONCURRENT
            info.queueFamilyIndexCount = 2
            info.pQueueFamilyIndices = UnsafePointer(queueFamiliesIndices.pointer)
        }
        let handlePointer = try device.create(with: info)

        try super.init(device: device, handlePointer: handlePointer)
    }

    public func getImages() throws -> [Image] {
        return try device.loadDataArray(for: handle, using: vkGetSwapchainImagesKHR)
            .compactMap { $0 }
            .map {
                try Image(device: device, format: imageFormat, handle: $0)
            }
    }
}
