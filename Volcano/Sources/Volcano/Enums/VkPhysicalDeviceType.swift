//
//  VkPhysicalDeviceType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021.
//

import CVulkan

public typealias VkPhysicalDeviceType = CVulkan.VkPhysicalDeviceType

public extension VkPhysicalDeviceType {
    static let other: Self = .VK_PHYSICAL_DEVICE_TYPE_OTHER
    static let integrated: Self = .VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
    static let discrete: Self = .VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU
    static let virtual: Self = .VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU
    static let cpu: Self = .VK_PHYSICAL_DEVICE_TYPE_CPU
}
