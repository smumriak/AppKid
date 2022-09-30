//
//  Buffer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.11.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public typealias VkDeviceSize = CVulkan.VkDeviceSize

public final class BufferDescriptor {
    public var size: VkDeviceSize = .zero
    public var usage: VkBufferUsageFlagBits = []
    public var flags: VkBufferCreateFlagBits = []
    public var requiredMemoryProperties: VkMemoryPropertyFlagBits = []
    public var preferredMemoryProperties: VkMemoryPropertyFlagBits = []

    public var accessQueueFamiliesIndices: [CUnsignedInt] = []
    public func setAccessQueues(_ accessQueues: [Queue]) {
        accessQueueFamiliesIndices = accessQueues.familyIndices
    }

    public var sharingMode: VkSharingMode {
        return accessQueueFamiliesIndices.count > 1 ? .concurrent : .exclusive
    }

    @LavaBuilder<VkBufferCreateInfo>
    public var builder: LavaBuilder<VkBufferCreateInfo> {
        \.flags <- flags
        \.size <- size
        \.usage <- usage
        \.sharingMode <- sharingMode
        (\.queueFamilyIndexCount, \.pQueueFamilyIndices) <- accessQueueFamiliesIndices
    }

    public func withUnsafeBufferCreateInfoPointer<T>(_ body: (UnsafePointer<VkBufferCreateInfo>) throws -> (T)) rethrows -> T {
        try builder(body)
    }

    public init() {}

    public init(stagingWithSize stagingSize: VkDeviceSize, accessQueues: [Queue]) {
        size = stagingSize
        usage = [.transferSource]
        requiredMemoryProperties = [.hostVisible, .hostCoherent]
        
        setAccessQueues(accessQueues)
    }
}

public class Buffer: DeviceEntity<VkBuffer_T> {
    public let size: VkDeviceSize
    public let usage: VkBufferUsageFlagBits
    public let sharingMode: VkSharingMode
    public let memoryChunk: MemoryChunk

    public init(device: Device, handle: SharedPointer<VkBuffer_T>, size: VkDeviceSize, usage: VkBufferUsageFlagBits, sharingMode: VkSharingMode, memoryChunk: MemoryChunk, shouldBind: Bool = true) throws {
        self.size = size
        self.usage = usage
        self.sharingMode = sharingMode
        self.memoryChunk = memoryChunk

        try super.init(device: device, handle: handle)

        if shouldBind {
            try memoryChunk.bind(to: self)
        }
    }

    public init(device: Device, descriptor: BufferDescriptor, shouldBind: Bool = true) throws {
        let handle: SharedPointer<VkBuffer_T> = try descriptor.withUnsafeBufferCreateInfoPointer { info in
            return try device.create(with: info)
        }

        self.size = descriptor.size
        self.usage = descriptor.usage
        self.sharingMode = descriptor.sharingMode
        self.memoryChunk = try device.memoryAllocator.allocate(for: handle, descriptor: descriptor)

        try super.init(device: device, handle: handle)

        if shouldBind {
            try memoryChunk.bind(to: self)
        }
    }
}
