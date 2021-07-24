//
//  VkCommandBufferLevel.swift
//  Volcano
//
//  Created by Serhii Mumriak on 07.12.2020.
//

import CVulkan

public typealias VkCommandBufferLevel = CVulkan.VkCommandBufferLevel

public extension VkCommandBufferLevel {
    static let primary: Self = .VK_COMMAND_BUFFER_LEVEL_PRIMARY
    static let secondary: Self = .VK_COMMAND_BUFFER_LEVEL_SECONDARY
}
