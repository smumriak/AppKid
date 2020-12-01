//
//  Buffer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.11.2020.
//

import TinyFoundation
import CVulkan

public class Buffer: VulkanDeviceEntity<SmartPointer<VkBuffer_T>> {
    public let size: VkDeviceSize
    public let usage: VkBufferUsageFlagBits
    public let sharingMode: VkSharingMode
    public let memoryChunk: MemoryChunk

    public init(device: Device, size: VkDeviceSize, usage: VkBufferUsageFlagBits, sharingMode: VkSharingMode = .exclusive, memoryProperties: VkMemoryPropertyFlagBits) throws {
        var info = VkBufferCreateInfo()
        info.sType = .bufferCreateInfo
        info.size = size
        info.usage = usage.rawValue
        info.sharingMode = sharingMode

        let handlePointer = try device.create(with: &info)

        let memoryTypes = device.physicalDevice.memoryTypes

        let memoryRequirements = try device.memoryRequirements(for: handlePointer)

        let memoryTypeAndIndexOptional = memoryTypes.enumerated().first { offset, element -> Bool in
            let flags = VkMemoryPropertyFlagBits(rawValue: element.propertyFlags)

            return (memoryRequirements.memoryTypeBits & (1 << offset)) != 0 && flags.contains(memoryProperties)
        }

        guard let (memoryIndex, memoryType) = memoryTypeAndIndexOptional else {
            throw VulkanError.noSuitableMemoryTypeAvailable
        }

        let memoryChunk = try MemoryChunk(device: device, size: memoryRequirements.size, memoryIndex: CUnsignedInt(memoryIndex), properties: VkMemoryPropertyFlagBits(rawValue: memoryType.propertyFlags))

        try vulkanInvoke {
            vkBindBufferMemory(device.handle, handlePointer.pointer, memoryChunk.handle, 0)
        }

        self.memoryChunk = memoryChunk

        self.size = size
        self.usage = usage
        self.sharingMode = sharingMode

        try super.init(device: device, handlePointer: handlePointer)
    }
}
