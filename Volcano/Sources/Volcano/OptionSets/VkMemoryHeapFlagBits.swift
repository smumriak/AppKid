//
//  VkMemoryHeapFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkMemoryHeapFlagBits = CVulkan.VkMemoryHeapFlagBits

public extension VkMemoryHeapFlagBits {
    static let deviceLocal: Self = .VK_MEMORY_HEAP_DEVICE_LOCAL_BIT
    static let multiInstance: Self = .VK_MEMORY_HEAP_MULTI_INSTANCE_BIT
    static let multiInstanceKhr: Self = .VK_MEMORY_HEAP_MULTI_INSTANCE_BIT_KHR
}
