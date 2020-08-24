//
//  VkCommandPoolCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension VkCommandPoolCreateFlagBits {
    public static let transient = VK_COMMAND_POOL_CREATE_TRANSIENT_BIT
    public static let resetCommandBuffer = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
    public static let protected = VK_COMMAND_POOL_CREATE_PROTECTED_BIT
}
