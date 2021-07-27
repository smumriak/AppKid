//
//  Semaphore.swift
//  Volcano
//
//  Created by Serhii Mumriak on 12.08.2020.
//

import TinyFoundation
import CVulkan

public class AbstractSemaphore: VulkanDeviceEntity<SmartPointer<VkSemaphore_T>> {}

public class Semaphore: AbstractSemaphore {
    public init(device: Device) throws {
        var info = VkSemaphoreCreateInfo(sType: .semaphoreCreateInfo, pNext: nil, flags: 0)

        let handlePointer = try device.create(with: &info)

        try super.init(device: device, handlePointer: handlePointer)
    }
}
