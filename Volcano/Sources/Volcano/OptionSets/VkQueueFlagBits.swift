//
//  VkQueueFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkQueueFlagBits {
    static let graphics = VK_QUEUE_GRAPHICS_BIT
    static let compute = VK_QUEUE_COMPUTE_BIT
    static let transfer = VK_QUEUE_TRANSFER_BIT
    static let sparseBinding = VK_QUEUE_SPARSE_BINDING_BIT
    static let protected = VK_QUEUE_PROTECTED_BIT
}
