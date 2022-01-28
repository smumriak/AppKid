//
//  Image.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation
import CVulkan

public final class Image: VulkanDeviceEntity<SmartPointer<VkImage_T>> {
    public let format: VkFormat

    public init(device: Device, handlePointer: SmartPointer<VkImage_T>, format: VkFormat) throws {
        self.format = format
        try super.init(device: device, handlePointer: handlePointer)
    }

    public convenience init(device: Device, swapchainImageHandle handle: VkImage, format: VkFormat) throws {
        try self.init(device: device, handlePointer: SmartPointer(with: handle), format: format)
    }
    
    public convenience init(device: Device, descriptor: ImageDescriptor) throws {
        let handlePointer = try descriptor.withUnsafeImageCreateInfoPointer { info in
            try device.create(with: info)
        }

        try self.init(device: device, handlePointer: handlePointer, format: descriptor.format)
    }
}

public class ImageDescriptor {
    public var flags: VkImageCreateFlagBits = []
    public var imageType: VkImageType = .type2D
    public var format: VkFormat = .rgba8UNorm
    public var extent: VkExtent3D = .zero
    public var mipLevels: CUnsignedInt = 0
    public var arrayLayers: CUnsignedInt = 0
    public var samples: VkSampleCountFlagBits = .one
    public var tiling: VkImageTiling = .optimal
    public var usage: VkImageUsageFlagBits = []
    public var sharingMode: VkSharingMode = .exclusive
    public var queueFamilyIndices: [CUnsignedInt] = []
    public var initialLayout: VkImageLayout = .undefined
    public var requiredMemoryProperties: VkMemoryPropertyFlagBits = []
    public var preferredMemoryProperties: VkMemoryPropertyFlagBits = []

    public func setAccessQueues(_ accessQueues: [Queue]) {
        queueFamilyIndices = accessQueues.familyIndices
    }

    public func withUnsafeImageCreateInfoPointer<T>(_ body: (UnsafePointer<VkImageCreateInfo>) throws -> (T)) rethrows -> T {
        return try queueFamilyIndices.withUnsafeBufferPointer { queueFamilyIndices in
            var info = VkImageCreateInfo.new()

            info.flagsBits = flags
            info.imageType = imageType
            info.format = format
            info.extent = extent
            info.mipLevels = mipLevels
            info.arrayLayers = arrayLayers
            info.samples = samples
            info.tiling = tiling
            info.usageFlagsBits = usage
            info.sharingMode = sharingMode
            
            info.queueFamilyIndexCount = CUnsignedInt(queueFamilyIndices.count)
            info.pQueueFamilyIndices = queueFamilyIndices.baseAddress!

            info.initialLayout = initialLayout

            return try withUnsafePointer(to: &info) { info in
                return try body(info)
            }
        }
    }
}

public extension VkImageCreateInfo {
    var flagsBits: VkImageCreateFlagBits {
        get { VkImageCreateFlagBits(rawValue: flags) }
        set { flags = newValue.rawValue }
    }

    var usageFlagsBits: VkImageUsageFlagBits {
        get { VkImageUsageFlagBits(rawValue: usage) }
        set { usage = newValue.rawValue }
    }
}
