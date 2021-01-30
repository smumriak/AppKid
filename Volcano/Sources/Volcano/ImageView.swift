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

    public init(image: Image, descriptor: ImageViewDescriptor) throws {
        self.image = image
        self.imageFormat = descriptor.format
        
        let device = image.device

        let handlePointer: SmartPointer<VkImageView_T> = try descriptor.withUnsafeImageViewCreateInfoPointer(for: image) { info in
            return try device.create(with: info)
        }

        try super.init(device: device, handlePointer: handlePointer)
    }
}

public extension VkComponentMapping {
    static let identity = VkComponentMapping(r: .identity, g: .identity, b: .identity, a: .identity)
}

public class ImageViewDescriptor {
    public var flags: VkImageViewCreateFlagBits = []
    public var type: VkImageViewType = .type2D
    public var format: VkFormat = .rgba8UNorm
    public var componentMapping: VkComponentMapping = .identity

    public var aspect: VkImageAspectFlagBits = []
    public var baseMipLevel: CUnsignedInt = 0
    public var levelCount: CUnsignedInt = 1
    public var baseArrayLayer: CUnsignedInt = 0
    public var layerCount: CUnsignedInt = 1

    internal func withUnsafeImageViewCreateInfoPointer<T>(for image: Image, _ body: (UnsafePointer<VkImageViewCreateInfo>) throws -> (T)) rethrows -> T {
        var subresourceRange = VkImageSubresourceRange()
        subresourceRange.aspectMask = aspect.rawValue
        subresourceRange.baseMipLevel = baseMipLevel
        subresourceRange.levelCount = levelCount
        subresourceRange.baseArrayLayer = baseArrayLayer
        subresourceRange.layerCount = layerCount

        var info = VkImageViewCreateInfo()
        info.sType = .imageViewCreateInfo
        info.flags = flags.rawValue
        info.image = image.handle
        info.viewType = type
        info.format = format
        info.components = componentMapping
        info.subresourceRange = subresourceRange

        return try withUnsafePointer(to: &info) { info in
            return try body(info)
        }
    }
}
