//
//  ImageView.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation
import CVulkan

public final class ImageView: DeviceEntity<VkImageView_T> {
    public unowned let image: Image
    public let imageFormat: VkFormat
    public let subresourceRange: VkImageSubresourceRange
    public let aspect: VkImageAspectFlagBits

    public init(image: Image, descriptor: ImageViewDescriptor) throws {
        self.image = image
        self.imageFormat = descriptor.format
        
        let device = image.device

        let handle: SharedPointer<VkImageView_T> = try descriptor.withUnsafeImageViewCreateInfoPointer(for: image) { info in
            return try device.create(with: info)
        }

        subresourceRange = descriptor.subresourceRange
        aspect = descriptor.aspect

        try super.init(device: device, handle: handle)
    }
}

public extension VkComponentMapping {
    static let identity = VkComponentMapping(r: .identity, g: .identity, b: .identity, a: .identity)
}

public class ImageViewDescriptor {
    public var flags: VkImageViewCreateFlagBits = []
    public var type: VkImageViewType = .twoDimensions
    public var format: VkFormat = .rgba8UNorm
    public var componentMapping: VkComponentMapping = .identity

    public var aspect: VkImageAspectFlagBits = .color
    public var baseMipLevel: CUnsignedInt = 0
    public var levelCount: CUnsignedInt = 1
    public var baseArrayLayer: CUnsignedInt = 0
    public var layerCount: CUnsignedInt = 1

    internal var subresourceRange: VkImageSubresourceRange {
        var result = VkImageSubresourceRange()

        result.aspectMask = aspect.rawValue
        result.baseMipLevel = baseMipLevel
        result.levelCount = levelCount
        result.baseArrayLayer = baseArrayLayer
        result.layerCount = layerCount

        return result
    }

    @LavaBuilder<VkImageViewCreateInfo>
    public func builder(for image: Image) -> LavaContainer<VkImageViewCreateInfo> {
        \.flags <- flags
        \.image <- image
        \.viewType <- type
        \.format <- format
        \.components <- componentMapping
        \.subresourceRange <- subresourceRange
    }

    public func withUnsafeImageViewCreateInfoPointer<T>(for image: Image, _ body: (UnsafePointer<VkImageViewCreateInfo>) throws -> (T)) rethrows -> T {
        let builder = builder(for: image)
        return try builder(body)
    }
}
