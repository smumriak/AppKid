//
//  PhysicalDeviceEntityInfo.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2020.
//

public protocol PhysicalDeviceEntityInfo: EntityInfo {
    typealias Parent = VkPhysicalDevice.Pointee
}

extension VkDeviceCreateInfo: PhysicalDeviceEntityInfo {
    public typealias Result = VkDevice.Pointee
    public static let createFunction: CreateFunction = vkCreateDevice
    public static let deleteFunction: DeleteFunction = { physicalDevice, device, allocator in
        vkDestroyDevice(device, allocator)
    }
}
