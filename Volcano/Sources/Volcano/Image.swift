//
//  Image.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation
import CVulkan

public final class Image: DeviceEntity<VkImage_T> {
    public let format: VkFormat

    public init(device: Device, handle: SharedPointer<VkImage_T>, format: VkFormat) throws {
        self.format = format
        try super.init(device: device, handle: handle)
    }

    public convenience init(device: Device, swapchainImageHandle handle: VkImage, format: VkFormat) throws {
        try self.init(device: device, handle: SharedPointer(nonOwning: handle), format: format)
    }
    
    public convenience init(device: Device, descriptor: ImageDescriptor) throws {
        let handle = try descriptor.withUnsafeImageCreateInfoPointer { info in
            try device.create(with: info)
        }

        try self.init(device: device, handle: handle, format: descriptor.format)
    }
}

public class ImageDescriptor {
    public var flags: VkImageCreateFlagBits = []
    public var imageType: VkImageType = .twoDimensions
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

    @LavaBuilder<VkImageCreateInfo>
    public var builder: LavaBuilder<VkImageCreateInfo> {
        \.flagsBits <- flags
        \.imageType <- imageType
        \.format <- format
        \.extent <- extent
        \.mipLevels <- mipLevels
        \.arrayLayers <- arrayLayers
        \.samples <- samples
        \.tiling <- tiling
        \.usageFlagsBits <- usage
        \.sharingMode <- sharingMode
        (\.queueFamilyIndexCount, \.pQueueFamilyIndices) <- queueFamilyIndices
        \.initialLayout <- initialLayout
    }

    public func withUnsafeImageCreateInfoPointer<T>(_ body: (UnsafePointer<VkImageCreateInfo>) throws -> (T)) rethrows -> T {
        try builder(body)
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
