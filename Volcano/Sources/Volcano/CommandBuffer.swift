//
//  CommandBuffer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class CommandBuffer: VulkanDeviceEntity<SmartPointer<VkCommandBuffer_T>> {
    public let fence: Fence

    public init(commandPool: CommandPool) throws {
        let device = commandPool.device

        var commandBufferAllocationInfo = VkCommandBufferAllocateInfo()
        commandBufferAllocationInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
        commandBufferAllocationInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
        commandBufferAllocationInfo.commandPool = commandPool.handle
        commandBufferAllocationInfo.commandBufferCount = 1

        let handle = try device.allocateMemory(info: &commandBufferAllocationInfo, using: vkAllocateCommandBuffers)
        let handlePointer = SmartPointer(with: handle) { [unowned device, unowned commandPool] in
            var mutablePointer: VkCommandBuffer? = $0
            vkFreeCommandBuffers(device.handle, commandPool.handle, 1, &mutablePointer)
        }

        self.fence = try Fence(device: device)

        try super.init(device: commandPool.device, handlePointer: handlePointer)
    }
}
