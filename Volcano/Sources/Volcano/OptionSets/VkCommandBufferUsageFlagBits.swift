//
//  VkCommandBufferUsageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkCommandBufferUsageFlagBits = CVulkan.VkCommandBufferUsageFlagBits

public extension VkCommandBufferUsageFlagBits {
    static let oneTimeSubmit: Self = .VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    static let renderPassContinue: Self = .VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT
    static let simultaneousUse: Self = .VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT
}
