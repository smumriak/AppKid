//
//  TimelineSemaphore.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2021.
//

import TinyFoundation
import CVulkan

public final class TimelineSemaphore: VulkanDeviceEntity<SmartPointer<VkSemaphore_T>> {
    public init(device: Device) throws {
        var info = VkSemaphoreCreateInfo(sType: .semaphoreCreateInfo, pNext: nil, flags: 0)

        let handlePointer = try device.create(with: &info)

        try super.init(device: device, handlePointer: handlePointer)
    }

    var value: UInt64 {
        get throws {
            return 0
        }
    }

    func wait(timeout: UInt64) throws {
    }

    func signal(with value: UInt64) throws {
    }
}
