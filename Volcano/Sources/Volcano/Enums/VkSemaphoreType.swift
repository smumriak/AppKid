//
//  VkSemaphoreType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021.
//

import CVulkan

public typealias VkSemaphoreType = CVulkan.VkSemaphoreType

public extension VkSemaphoreType {
    static let binary: Self = .VK_SEMAPHORE_TYPE_BINARY
    static let timeline: Self = .VK_SEMAPHORE_TYPE_TIMELINE
}
