//
//  VulkanEntity.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import TinyFoundation

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
    
    public init<Info: SimpleEntityInfo>(info: Info.Type, device: Device, @Lava<Info> _ content: () throws -> (LavaContainer<Info>)) throws where Info.Parent == VkDevice.Pointee, Info.Result == Entity {
        let handle: Handle = try device.buildEntity(Info.self, content)
        self.device = device

        super.init(handle: handle)
    }

    // smumriak: This got broken in swift 5.9. Again. Old hack does not work anymore. Leaving it for reference in case I would want to implement it in future
    // public init(device: Device, @Lava<Entity.Info> _ content: () throws -> (LavaContainer<Entity.Info>)) throws where Entity: CreateableFromEntityInfo, Entity.Info: SimpleEntityInfo, Entity.Info.Parent == VkDevice.Pointee {
    //     let handle: Handle = try device.buildEntity(content)
    //     self.device = device

    //     super.init(handle: handle)
    // }
}

public extension DeviceEntity {
    @inlinable @inline(__always)
    var physicalDevice: PhysicalDevice { device.physicalDevice }

    @inlinable @inline(__always)
    var instance: Instance { device.instance }
}
