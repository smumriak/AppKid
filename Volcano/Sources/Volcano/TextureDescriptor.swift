//
//  TextureDescriptor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public struct TextureUsage: OptionSet {
    public typealias RawValue = UInt
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public static let unknown: TextureUsage = []
    public static let shaderRead = TextureUsage(rawValue: 1 << 0)
    public static let shaderWrite = TextureUsage(rawValue: 1 << 1)
    public static let renderTarget = TextureUsage(rawValue: 1 << 2)
    public static let pixelFormatView = TextureUsage(rawValue: 1 << 4)
}

public final class TextureDescriptor {
    public var textureType: VkImageViewType = .type2D
    public var pixelFormat: VkFormat = .rgba8UNorm
    public var width: Int = 1
    public var height: Int = 1
    public var depth: Int = 1
    public var mipmapLevelCount: Int = 1
    public var sampleCount: VkSampleCountFlagBits = .one
    public var arrayLength: Int = 1
    public var usage: TextureUsage = .shaderRead
    public var swizzle: VkComponentMapping = .identity
    public var tiling: VkImageTiling = .optimal

    public var isDepthTexture: Bool = false
    public var isStencilTexture: Bool = false
    public var initialLayout: VkImageLayout = .undefined
    public var requiredMemoryProperties: VkMemoryPropertyFlagBits = []
    public var preferredMemoryProperties: VkMemoryPropertyFlagBits = []

    public var accessQueueFamiliesIndices: [CUnsignedInt] = []
    public func setAccessQueues(_ accessQueues: [Queue]) {
        accessQueueFamiliesIndices = accessQueues.familyIndices
    }
}

public extension TextureDescriptor {
    static func texture2DDescriptor(pixelFormat: VkFormat, width: Int, height: Int, mipmapped: Bool) -> TextureDescriptor {
        let result = TextureDescriptor()

        result.textureType = .type2D
        result.pixelFormat = pixelFormat
        result.width = width
        result.height = height

        return result
    }
}

public extension TextureDescriptor {
    var imageDescriptor: ImageDescriptor {
        let result = ImageDescriptor()

        result.imageType = textureType.imageType
        result.format = pixelFormat
        result.extent = VkExtent3D(width: CUnsignedInt(width), height: CUnsignedInt(height), depth: CUnsignedInt(depth))
        result.mipLevels = CUnsignedInt(mipmapLevelCount)
        result.arrayLayers = CUnsignedInt(arrayLength)
        result.samples = sampleCount
        result.tiling = tiling
        result.requiredMemoryProperties = requiredMemoryProperties
        result.preferredMemoryProperties = preferredMemoryProperties

        var imageUsageFlags: VkImageUsageFlagBits = []

        if usage.contains(.shaderRead) {
            imageUsageFlags.formUnion([.transferSource, .sampled, .inputAttachment])
        }

        if usage.contains(.renderTarget) {
            imageUsageFlags.formUnion(.transferDestination)

            if isDepthTexture || isStencilTexture {
                imageUsageFlags.formUnion(.depthStencilAttachment)
            } else {
                imageUsageFlags.formUnion(.colorAttachment)
            }
        }

        if usage.contains(.shaderWrite) {
            imageUsageFlags.formUnion(.storage)
        }

        result.usage = imageUsageFlags

        if accessQueueFamiliesIndices.count < 2 {
            result.sharingMode = .exclusive
        } else {
            result.sharingMode = .concurrent
        }
            
        result.queueFamilyIndices = accessQueueFamiliesIndices

        result.initialLayout = initialLayout

        return result
    }

    var imageViewDescriptor: ImageViewDescriptor {
        let result = ImageViewDescriptor()
        // palkovnik:TODO:Add proper calculation of this things instad of hardcode. Too late in the night - brain does not work.
        result.flags = []
        result.type = textureType
        result.format = pixelFormat
        result.componentMapping = swizzle
        result.aspect = .color
        result.baseMipLevel = 0
        result.levelCount = 1
        result.baseArrayLayer = 0
        result.layerCount = 1

        return result
    }
}
