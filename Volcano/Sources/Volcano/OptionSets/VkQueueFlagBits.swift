//
//  VkQueueFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension VkQueueFlagBits {
    public static let graphics = VK_QUEUE_GRAPHICS_BIT
    public static let compute = VK_QUEUE_COMPUTE_BIT
    public static let transfer = VK_QUEUE_TRANSFER_BIT
    public static let sparseBinding = VK_QUEUE_SPARSE_BINDING_BIT
    public static let protected = VK_QUEUE_PROTECTED_BIT
}
