//
//  VulkanQueue.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class VulkanQueue: VulkanDeviceEntity<SimplePointer<VkQueue_T>> {
    public let familyIndex: Int
    public let queueIndex: Int

    public init(device: VulkanDevice, familyIndex: Int, queueIndex: Int) throws {
        self.familyIndex = familyIndex
        self.queueIndex = queueIndex

        var handle: VkQueue?
        try vulkanInvoke {
            vkGetDeviceQueue(device.handle, CUnsignedInt(familyIndex), CUnsignedInt(queueIndex), &handle)
        }

        try super.init(device: device, handlePointer: SimplePointer(with: handle!))
    }
}
