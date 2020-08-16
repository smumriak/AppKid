//
//  CommandPool.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class CommandPool: VulkanDeviceEntity<SmartPointer<VkCommandPool_T>> {
    public let queue: Queue

    public init(device: Device, queue: Queue, flags: VkCommandPoolCreateFlagBits = .resetCommandBuffer) throws {
        self.queue = queue

        var info = VkCommandPoolCreateInfo()
        info.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
        info.flags = flags.rawValue
        info.queueFamilyIndex = CUnsignedInt(queue.familyIndex)

        let handlePointer = try device.create(with: info)
        
        try super.init(device: device, handlePointer: handlePointer)
    }
}
