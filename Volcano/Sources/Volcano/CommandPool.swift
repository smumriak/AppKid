//
//  CommandPool.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import TinyFoundation
import CVulkan

public final class CommandPool: VulkanDeviceEntity<SmartPointer<VkCommandPool_T>> {
    public let queue: Queue

    public init(device: Device, queue: Queue, flags: VkCommandPoolCreateFlagBits = .resetCommandBuffer) throws {
        self.queue = queue

        var info = VkCommandPoolCreateInfo()
        info.sType = .commandPoolCreateInfo
        info.flags = flags.rawValue
        info.queueFamilyIndex = CUnsignedInt(queue.familyIndex)

        let handlePointer = try device.create(with: &info)
        
        try super.init(device: device, handlePointer: handlePointer)
    }

    public func createCommandBuffer(level: VkCommandBufferLevel = .primary) throws -> CommandBuffer {
        return try createCommandBuffers(count: 1, level: level).first!
    }

    public func createCommandBuffers(count: UInt = 1, level: VkCommandBufferLevel = .primary) throws -> [CommandBuffer] {
        var info = VkCommandBufferAllocateInfo()
        info.sType = .commandBufferAllocateInfo
        info.level = level
        info.commandPool = handle
        info.commandBufferCount = CUnsignedInt(count)

        var handles = Array<VkCommandBuffer?>(repeating: nil, count: Int(count))

        try handles.withUnsafeMutableBufferPointer { handles in
            try vulkanInvoke {
                vkAllocateCommandBuffers(device.handle, &info, handles.baseAddress!)
            }
        }

        return try handles
            .compactMap { $0 }
            .map { handle in
                let handlePointer = SmartPointer(with: handle) { [device, self] in
                    var mutablePointer: VkCommandBuffer? = $0
                    vkFreeCommandBuffers(device.handle, self.handle, 1, &mutablePointer)
                }

                return try CommandBuffer(device: device, handlePointer: handlePointer)
            }
    }
}
