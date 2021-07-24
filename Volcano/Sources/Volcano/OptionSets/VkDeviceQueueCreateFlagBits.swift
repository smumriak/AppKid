//
//  VkDeviceQueueCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkDeviceQueueCreateFlagBits = CVulkan.VkDeviceQueueCreateFlagBits

public extension VkDeviceQueueCreateFlagBits {
    static let protected: Self = .VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT
}
