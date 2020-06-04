//
//  VulkanCommandPool.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class VulkanCommandPool: VulkanDeviceEntity<SmartPointer<VkCommandPool_T>> {
    public let queue: VulkanQueue

    public init(device: VulkanDevice, queue: VulkanQueue) throws {
        self.queue = queue

        var commandPoolCreationInfo = VkCommandPoolCreateInfo()
        commandPoolCreationInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
        commandPoolCreationInfo.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT.rawValue
        commandPoolCreationInfo.queueFamilyIndex = CUnsignedInt(queue.familyIndex)

        let handle = try device.createEntity(info: &commandPoolCreationInfo, using: vkCreateCommandPool)
        let handlePointer = SmartPointer(with: handle) { [unowned device] in
            vkDestroyCommandPool(device.handle, $0, nil)
        }

        try super.init(device: device, handlePointer: handlePointer)
    }
}
