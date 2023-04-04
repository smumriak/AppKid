//
//  VulkanEntity.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import TinyFoundation
import CVulkan

open class InstanceEntity<Entity>: SharedPointerStorage<Entity> {
    public internal(set) var instance: Instance

    public init(instance: Instance, handle: Handle) throws {
        self.instance = instance
        super.init(handle: handle)
    }
}

open class PhysicalDeviceEntity<Entity>: SharedPointerStorage<Entity> {
    public internal(set) var physicalDevice: PhysicalDevice

    @inlinable @inline(__always)
    public var instance: Instance { physicalDevice.instance }

    public init(physicalDevice: PhysicalDevice, handle: Handle) throws {
        self.physicalDevice = physicalDevice

        super.init(handle: handle)
    }
}

open class DeviceEntity<Entity: VkDeviceEntity>: SharedPointerStorage<Entity> {
    public internal(set) var device: Device

    public init(device: Device, handle: Handle) throws {
        self.device = device

        super.init(handle: handle)
    }
    
    public init(device: Device, @Lava<Entity.Info> _ content: () throws -> (LavaContainer<Entity.Info>)) throws where Entity: CreateableFromSingleEntityInfo, Entity.Info: SimpleEntityInfo, Entity.Info.Parent == VkDevice.Pointee {
        let handle: Handle = try device.buildEntity(content)
        self.device = device

        super.init(handle: handle)
    }
}

public extension DeviceEntity {
    @inlinable @inline(__always)
    var physicalDevice: PhysicalDevice { device.physicalDevice }

    @inlinable @inline(__always)
    var instance: Instance { device.instance }
}
