//
//  VulkanPhisycalDevice.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

extension VkPhysicalDevice_T: VulkanEntityFactory {}

public final class VulkanPhysicalDevice: VulkanEntity<SimplePointer<VkPhysicalDevice_T>> {
    public let properties: VkPhysicalDeviceProperties
    public let queueFamiliesProperties: [VkQueueFamilyProperties]

    internal override init(instance: VulkanInstance, handlePointer: SimplePointer<VkPhysicalDevice_T>) throws {
        properties = try handlePointer.loadData(using: vkGetPhysicalDeviceProperties)
        queueFamiliesProperties = try handlePointer.loadDataArray(using: vkGetPhysicalDeviceQueueFamilyProperties)

        try super.init(instance: instance, handlePointer: handlePointer)
    }

    public func createLogicalDevice() throws -> VulkanDevice {
        return try VulkanDevice(physicalDevice: self)
    }
}
