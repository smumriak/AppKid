//
//  Fence.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import TinyFoundation
import CVulkan

public final class Fence: VulkanDeviceEntity<SmartPointer<VkFence_T>> {
    public init(device: Device, flags: VkFenceCreateFlagBits = []) throws {
        let info = VkFenceCreateInfo(sType: .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO, pNext: nil, flags: flags.rawValue)
        
        let handlePointer = try device.create(with: info)
        
        try super.init(device: device, handlePointer: handlePointer)
    }
    
    public func wait(timeout: UInt64 = .max) throws {
        var handleOptional: VkFence? = handle

        try vulkanInvoke {
            vkWaitForFences(device.handle, 1, &handleOptional, true.vkBool, timeout)
        }
    }
    
    public func reset() throws {
        var handleOptional: VkFence? = handle

        try vulkanInvoke {
            vkResetFences(device.handle, 1, &handleOptional)
        }
    }
}
