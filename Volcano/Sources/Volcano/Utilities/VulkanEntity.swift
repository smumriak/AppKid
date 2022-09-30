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
    
    // smumriak:FIXME: when making this initializer to consume `Entity.Info` directly in `content` argument type declaration complier crashes. presumably, because it fails to resolve types recursivelly or something. making initializer generic with specifying the `NoCompilerCrashType` as `Entity.Info` crash is avoided
    public init<NoCompilerCrashType>(device: Device, @LavaBuilder<NoCompilerCrashType> _ content: () throws -> (LavaBuilder<NoCompilerCrashType>)) throws where Entity: CreateableFromSingleEntityInfo, Entity.Info: SimpleEntityInfo, Entity.Info.Parent == VkDevice.Pointee, NoCompilerCrashType == Entity.Info {
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
