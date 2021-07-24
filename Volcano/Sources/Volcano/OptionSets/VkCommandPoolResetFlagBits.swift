//
//  VkCommandPoolResetFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkCommandPoolResetFlagBits = CVulkan.VkCommandPoolResetFlagBits

public extension VkCommandPoolResetFlagBits {
    static let releaseResources: Self = .VK_COMMAND_POOL_RESET_RELEASE_RESOURCES_BIT
}
