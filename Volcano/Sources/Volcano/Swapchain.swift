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

    public init(device: Device, surface: Surface, size: VkExtent2D) throws {
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

        var swapchainCreationInfo = VkSwapchainCreateInfoKHR()
        swapchainCreationInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        swapchainCreationInfo.surface = surface.handle
        swapchainCreationInfo.minImageCount = imageCount
        swapchainCreationInfo.imageFormat = surface.imageFormat
        swapchainCreationInfo.imageColorSpace = surface.colorSpace
        swapchainCreationInfo.imageExtent = size
        swapchainCreationInfo.imageArrayLayers = 1
        swapchainCreationInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue
        swapchainCreationInfo.preTransform = surface.capabilities.currentTransform
        swapchainCreationInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
        swapchainCreationInfo.presentMode = presentMode

        var queueFamiliesIndices = UnsafeMutablePointer<CUnsignedInt>.allocate(capacity: 2)
        defer { queueFamiliesIndices.deallocate() }
        queueFamiliesIndices[0] = CUnsignedInt(device.graphicsQueueFamilyIndex)
        queueFamiliesIndices[1] = CUnsignedInt(device.presentationQueueFamilyIndex)

        if device.graphicsQueueFamilyIndex == device.presentationQueueFamilyIndex {
            swapchainCreationInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
            swapchainCreationInfo.queueFamilyIndexCount = 0
            swapchainCreationInfo.pQueueFamilyIndices = nil
        } else {
            swapchainCreationInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT
            swapchainCreationInfo.queueFamilyIndexCount = 2
            swapchainCreationInfo.pQueueFamilyIndices = UnsafePointer(queueFamiliesIndices)
        }

        let swapchain: VkSwapchainKHR = try device.createEntity(info: &swapchainCreationInfo, using: vkCreateSwapchainKHR)

        let handlePointer = SmartPointer(with: swapchain) { [unowned device] in
            vkDestroySwapchainKHR(device.handle, $0, nil)
        }

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
