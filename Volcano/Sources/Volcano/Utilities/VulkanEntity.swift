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

open class DeviceEntity<Entity>: SharedPointerStorage<Entity> {
    public internal(set) var device: Device

    @inlinable @inline(__always)
    public var physicalDevice: PhysicalDevice { device.physicalDevice }

    @inlinable @inline(__always)
    public var instance: Instance { device.instance }

    public init(device: Device, handle: Handle) throws {
        self.device = device

        super.init(handle: handle)
    }
}
