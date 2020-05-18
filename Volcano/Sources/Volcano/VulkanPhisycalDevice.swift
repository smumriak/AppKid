//
//  VulkanPhisycalDevice.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class VulkanPhysicalDevice: VulkanEntity<SimplePointer<VkPhysicalDevice_T>> {
    var properties: VkPhysicalDeviceProperties = VkPhysicalDeviceProperties()

    internal override init(instance: VulkanInstance, handlePointer: SimplePointer<VkPhysicalDevice_T>) throws {
        try super.init(instance: instance, handlePointer: handlePointer)

        try vulkanInvoke {
            vkGetPhysicalDeviceProperties(handle, &properties)
        }
    }

    public var newLogicalDevice: VulkanDevice {
        do {
            return try VulkanDevice(physicalDevice: self)
        } catch {
            fatalError("Failed to create vulkan logical device with error: \(error)")
        }
    }
}
