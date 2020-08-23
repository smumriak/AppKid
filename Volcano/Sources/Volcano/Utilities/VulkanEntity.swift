//
//  VulkanEntity.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

public class VulkanEntity<Entity>: VulkanHandle<Entity> where Entity: SmartPointerProtocol {
    public internal(set) var instance: Instance

    public init(instance: Instance, handlePointer: Entity) throws {
        self.instance = instance
        super.init(handlePointer: handlePointer)
    }
}

public class VulkanDeviceEntity<Entity>: VulkanEntity<Entity> where Entity: SmartPointerProtocol {
    public internal(set) var device: Device

    public init(device: Device, handlePointer: Entity) throws {
        self.device = device

        try super.init(instance: device.instance, handlePointer: handlePointer)
    }
}
