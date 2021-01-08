//
//  ImageView.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation
import CVulkan

public final class ImageView: VulkanDeviceEntity<SmartPointer<VkImageView_T>> {
    public unowned let image: Image
    public let imageFormat: VkFormat

    public init(image: Image, componentMapping: VkComponentMapping = .identity, flags: VkImageViewCreateFlagBits = []) throws {
        self.image = image
        self.imageFormat = image.format
        
        var subresourceRange = VkImageSubresourceRange()
        subresourceRange.aspectMask = VkImageAspectFlagBits.color.rawValue
        subresourceRange.baseMipLevel = 0
        subresourceRange.levelCount = 1
        subresourceRange.baseArrayLayer = 0
        subresourceRange.layerCount = 1

        var info = VkImageViewCreateInfo()
        info.sType = .imageViewCreateInfo
        info.image = image.handle
        info.viewType = .type2D
        info.format = image.format
        info.components = componentMapping
        info.subresourceRange = subresourceRange
        info.flags = flags.rawValue

        let device = image.device

        let handlePointer = try device.create(with: &info)

        try super.init(device: device, handlePointer: handlePointer)
    }
}

public extension VkComponentMapping {
    static let identity = VkComponentMapping(r: .identity, g: .identity, b: .identity, a: .identity)
}
