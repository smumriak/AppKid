//
//  VkCommandPoolCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkCommandPoolCreateFlagBits = CVulkan.VkCommandPoolCreateFlagBits

public extension VkCommandPoolCreateFlagBits {
    static let transient = VK_COMMAND_POOL_CREATE_TRANSIENT_BIT
    static let resetCommandBuffer = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
    static let protected = VK_COMMAND_POOL_CREATE_PROTECTED_BIT
}
