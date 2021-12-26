//
//  Swapchain.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.05.2020.
//

import TinyFoundation
import CVulkan

public final class Swapchain: VulkanDeviceEntity<SmartPointer<VkSwapchainKHR_T>> {
    public unowned let surface: Surface
    public var size: VkExtent2D
    public let imageFormat: VkFormat
    public let presentMode: VkPresentModeKHR
    internal let rawImages: [VkImage]

    public init(device: Device, surface: Surface, desiredPresentModes: [VkPresentModeKHR] = [.immediate], size: VkExtent2D, graphicsQueue: Queue, presentationQueue: Queue, usage: VkImageUsageFlagBits, compositeAlpha: VkCompositeAlphaFlagBitsKHR = [], oldSwapchain: Swapchain? = nil) throws {
        self.surface = surface
        self.size = size
        self.imageFormat = surface.imageFormat

        let capabilities = surface.capabilities

        let presentMode: VkPresentModeKHR

        if let desiredPresentMode = desiredPresentModes.first(where: { surface.presetModes.contains($0) }) {
            presentMode = desiredPresentMode
        } else {
            presentMode = .fifo
        }

        self.presentMode = presentMode

        let minImageCount = capabilities.minImageCount + 1
        // palkovnik:Spec says "maxImageCount is the maximum number of images the specified device supports for a swapchain created for the surface, and will be either 0, or greater than or equal to minImageCount. A value of 0 means that there is no limit on the number of images, though there may be limits related to the total amount of memory used by presentable images.". So this code adjusts accordingly
        let maxImageCount = capabilities.maxImageCount > 0 ? capabilities.maxImageCount : minImageCount

        let imageCount = min(minImageCount, maxImageCount)
        let queueFamiliesIndices = [graphicsQueue, presentationQueue].familyIndices

        let handlePointer: SmartPointer<VkSwapchainKHR_T> = try queueFamiliesIndices.withUnsafeBufferPointer { queueFamiliesIndices in
            var info = VkSwapchainCreateInfoKHR()
            info.sType = .swapchainCreateInfoKhr
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
            info.oldSwapchain = oldSwapchain?.handle

            if graphicsQueue.familyIndex == presentationQueue.familyIndex {
                info.imageSharingMode = .exclusive
            } else {
                info.imageSharingMode = .concurrent
            }

            info.queueFamilyIndexCount = CUnsignedInt(queueFamiliesIndices.count)
            info.pQueueFamilyIndices = queueFamiliesIndices.baseAddress!

            return try device.create(with: &info)
        }

        self.rawImages = try device.loadDataArray(for: handlePointer.pointer, using: vkGetSwapchainImagesKHR).compactMap { $0 }

        try super.init(device: device, handlePointer: handlePointer)
    }

    public func creteTextures() throws -> [Texture] {
        try rawImages.indices.map {
            try SwapchainTexture(swapchain: self, imageIndex: $0)
        }
    }

    public func getNextImageIndex(semaphore: Semaphore? = nil, fence: Fence? = nil, timeout: UInt64 = .max) throws -> Int {
        var result: CUnsignedInt = 0

        try vulkanInvoke {
            device.vkAcquireNextImageKHR(device.handle, handle, timeout, semaphore?.handle, fence?.handle, &result)
        }

        return Int(result)
    }
}
