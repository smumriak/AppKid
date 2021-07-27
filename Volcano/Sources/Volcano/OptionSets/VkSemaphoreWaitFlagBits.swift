//
//  VkSemaphoreWaitFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkSemaphoreWaitFlagBits = CVulkan.VkSemaphoreWaitFlagBits

public extension VkSemaphoreWaitFlagBits {
    static let any: Self = .VK_SEMAPHORE_WAIT_ANY_BIT
}
