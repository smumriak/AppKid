//
//  VulkanSwapchain.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class VulkanSwapchain: VulkanEntity<CustomDestructablePointer<VkSwapchainKHR_T>> {
    public unowned let surface: VulkanSurface

    public init(surface: VulkanSurface) throws {
        self.surface = surface

        let capabilities = surface.capabilities
        var extent = surface.capabilities.currentExtent
        if extent.width == .max {
            extent.width = surface.size.width
        }

        if extent.height == .max {
            extent.height = surface.size.height
        }

        let presentMode = VK_PRESENT_MODE_FIFO_KHR
        let imageCount = max(capabilities.minImageCount + 1, capabilities.maxImageCount)

        var swapchainCreationInfo = VkSwapchainCreateInfoKHR()
        swapchainCreationInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        swapchainCreationInfo.surface = surface.handle
        swapchainCreationInfo.minImageCount = imageCount
        swapchainCreationInfo.imageFormat = surface.imageFormat
        swapchainCreationInfo.imageColorSpace = surface.colorSpace
        swapchainCreationInfo.imageExtent = extent
        swapchainCreationInfo.imageArrayLayers = 1
        swapchainCreationInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue
        swapchainCreationInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
        swapchainCreationInfo.queueFamilyIndexCount = 0
        swapchainCreationInfo.pQueueFamilyIndices = nil
        swapchainCreationInfo.preTransform = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR
        swapchainCreationInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
        swapchainCreationInfo.presentMode = presentMode

        let swapchain: VkSwapchainKHR = try surface.device.handle.createEntity(info: &swapchainCreationInfo, using: vkCreateSwapchainKHR)

        let handlePointer = CustomDestructablePointer(with: swapchain) { [unowned surface] in
            vkDestroySwapchainKHR(surface.device.handle, $0, nil)
        }

        try super.init(instance: surface.instance, handlePointer: handlePointer)
    }
}
