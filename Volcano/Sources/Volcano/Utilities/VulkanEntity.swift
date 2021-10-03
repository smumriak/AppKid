//
//  VulkanEntity.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import TinyFoundation
import CVulkan

public protocol VulkanDeviceEntityProtocol: SmartPointerHandleStorageProtocol {}

open class VulkanEntity<Entity>: HandleStorage<Entity> where Entity: SmartPointerProtocol {
    public internal(set) var instance: Instance

    public init(instance: Instance, handlePointer: Entity) throws {
        self.instance = instance
        super.init(handlePointer: handlePointer)
    }
}

open class VulkanPhysicalDeviceEntity<Entity>: VulkanEntity<Entity> where Entity: SmartPointerProtocol {
    public internal(set) var physicalDevice: PhysicalDevice

    public init(physicalDevice: PhysicalDevice, handlePointer: Entity) throws {
        self.physicalDevice = physicalDevice

        try super.init(instance: physicalDevice.instance, handlePointer: handlePointer)
    }
}

open class VulkanDeviceEntity<Entity>: VulkanPhysicalDeviceEntity<Entity>, VulkanDeviceEntityProtocol where Entity: SmartPointerProtocol {
    public internal(set) var device: Device

    public init(device: Device, handlePointer: Entity) throws {
        self.device = device

        try super.init(physicalDevice: device.physicalDevice, handlePointer: handlePointer)
    }
}
