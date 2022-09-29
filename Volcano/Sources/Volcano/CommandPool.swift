//
//  CommandPool.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import TinyFoundation
import CVulkan

public final class CommandPool: DeviceEntity<VkCommandPool_T> {
    public let queue: Queue

    public init(device: Device, queue: Queue, flags: VkCommandPoolCreateFlagBits = .resetCommandBuffer) throws {
        self.queue = queue

        var info = VkCommandPoolCreateInfo.new()
        info.flags = flags.rawValue
        info.queueFamilyIndex = CUnsignedInt(queue.familyIndex)

        let handle = try device.create(with: &info)
        
        try super.init(device: device, handle: handle)
    }

    public func createCommandBuffer(level: VkCommandBufferLevel = .primary) throws -> CommandBuffer {
        return try createCommandBuffers(count: 1, level: level).first!
    }

    public func createCommandBuffers(count: UInt = 1, level: VkCommandBufferLevel = .primary) throws -> [CommandBuffer] {
        var info = VkCommandBufferAllocateInfo.new()
        info.level = level
        info.commandPool = pointer
        info.commandBufferCount = CUnsignedInt(count)

        var handles = Array<VkCommandBuffer?>(repeating: nil, count: Int(count))

        try handles.withUnsafeMutableBufferPointer { handles in
            try vulkanInvoke {
                vkAllocateCommandBuffers(device.pointer, &info, handles.baseAddress!)
            }
        }

        return try handles
            .compactMap { $0 }
            .map { handle in
                let handle = SharedPointer(with: handle) { [device, self] in
                    var mutablePointer: VkCommandBuffer? = $0
                    vkFreeCommandBuffers(device.pointer, self.pointer, 1, &mutablePointer)
                }

                return try CommandBuffer(device: device, handle: handle)
            }
    }
}
