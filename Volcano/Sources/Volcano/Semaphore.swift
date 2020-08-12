//
//  Semaphore.swift
//  Volcano
//
//  Created by Serhii Mumriak on 12.08.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class Semaphore: VulkanDeviceEntity<SmartPointer<VkSemaphore_T>> {
    public init(device: Device) throws {
        let info = VkSemaphoreCreateInfo(sType: VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, pNext: nil, flags: 0)

        let handlePointer = try device.create(with: info)

        try super.init(device: device, handlePointer: handlePointer)
    }
}
