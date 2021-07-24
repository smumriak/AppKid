//
//  VkQueueFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkQueueFlagBits = CVulkan.VkQueueFlagBits

public extension VkQueueFlagBits {
    static let graphics: Self = .VK_QUEUE_GRAPHICS_BIT
    static let compute: Self = .VK_QUEUE_COMPUTE_BIT
    static let transfer: Self = .VK_QUEUE_TRANSFER_BIT
    static let sparseBinding: Self = .VK_QUEUE_SPARSE_BINDING_BIT
    static let protected: Self = .VK_QUEUE_PROTECTED_BIT
}
