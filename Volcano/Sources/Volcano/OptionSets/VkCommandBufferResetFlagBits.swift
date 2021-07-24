//
//  VkCommandBufferResetFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkCommandBufferResetFlagBits = CVulkan.VkCommandBufferResetFlagBits

public extension VkCommandBufferResetFlagBits {
    static let releaseResources: Self = .VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT
}
