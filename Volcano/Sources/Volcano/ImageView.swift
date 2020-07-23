//
//  ImageView.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class ImageView: VulkanDeviceEntity<SmartPointer<VkImageView_T>> {
    public unowned let image: Image
    public let imageFormat: VkFormat

    public init(image: Image) throws {
        self.image = image
        self.imageFormat = image.format

        var componentMapping = VkComponentMapping()
        componentMapping.r = VK_COMPONENT_SWIZZLE_IDENTITY
        componentMapping.g = VK_COMPONENT_SWIZZLE_IDENTITY
        componentMapping.a = VK_COMPONENT_SWIZZLE_IDENTITY
        componentMapping.a = VK_COMPONENT_SWIZZLE_IDENTITY

        var subresourceRange = VkImageSubresourceRange()
        subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
        subresourceRange.baseMipLevel = 0
        subresourceRange.levelCount = 1
        subresourceRange.baseArrayLayer = 0
        subresourceRange.layerCount = 1

        var info = VkImageViewCreateInfo()
        info.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
        info.image = image.handle
        info.viewType = VK_IMAGE_VIEW_TYPE_2D
        info.format = image.format
        info.components = componentMapping
        info.subresourceRange = subresourceRange
        info.flags = 0

        let device = image.device

        let handlePointer = try device.create(with: &info)

        try super.init(device: device, handlePointer: handlePointer)
    }
}
