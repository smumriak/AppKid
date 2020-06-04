//
//  VulkanFence.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class VulkanFence: VulkanDeviceEntity<SmartPointer<VkFence_T>> {
    public init(device: VulkanDevice) throws {
        var fenceCreationInfo = VkFenceCreateInfo(sType: VK_STRUCTURE_TYPE_FENCE_CREATE_INFO, pNext: nil, flags: 0)

        let handle = try device.createEntity(info: &fenceCreationInfo, using: vkCreateFence)
        let handlePoitner = SmartPointer(with: handle, deleter: .custom({ [unowned device] in
            vkDestroyFence(device.handle, $0, nil)
        }))

        try super.init(device: device, handlePointer: handlePoitner)
    }
}
