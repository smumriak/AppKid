//
//  MemoryChunk.swift
//  Volcano
//
//  Created by Serhii Mumriak on 06.07.2020.
//

import TinyFoundation
import CVulkan

public class MemoryChunk: VulkanDeviceEntity<SmartPointer<VkDeviceMemory_T>> {
    public let parent: MemoryChunk?
    public let offset: VkDeviceSize
    public let size: VkDeviceSize
    public let properties: VkMemoryPropertyFlagBits

    public init(parent: MemoryChunk, offset: VkDeviceSize, size: VkDeviceSize) throws {
        if offset + size > parent.size {
            throw VulkanError.notEnoughParentMemory
        }

        self.parent = parent
        self.offset = offset + parent.offset
        self.size = size
        self.properties = parent.properties

        try super.init(device: parent.device, handlePointer: parent.handlePointer)
    }

    public init(device: Device, size: VkDeviceSize, memoryIndex: CUnsignedInt, properties: VkMemoryPropertyFlagBits) throws {
        var memoryAllocationInfo = VkMemoryAllocateInfo()
        memoryAllocationInfo.sType = .memoryAllocateInfo
        memoryAllocationInfo.allocationSize = size
        memoryAllocationInfo.memoryTypeIndex = memoryIndex

        let handlePointer = try device.allocateMemory(info: &memoryAllocationInfo)

        self.offset = 0
        self.size = size
        self.parent = nil
        self.properties = properties

        try super.init(device: device, handlePointer: handlePointer)
    }

    public func withMappedData<R>(body: (_ data: UnsafeMutableRawPointer, _ size: VkDeviceSize) throws -> (R)) throws -> R {
        // palkovnik:TODO:Check if memory can be mapped. Maybe separate read and write functions is better design
        var data: UnsafeMutableRawPointer? = nil
        try vulkanInvoke {
            vkMapMemory(device.handle, handle, offset, size, 0, &data)
        }

        let result: R = try body(data!, size)
 
        try vulkanInvoke {
            vkUnmapMemory(device.handle, handle)
        }

        return result
    }
}
