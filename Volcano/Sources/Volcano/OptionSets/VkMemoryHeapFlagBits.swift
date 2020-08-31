//
//  VkMemoryHeapFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkMemoryHeapFlagBits {
    static let deviceLocal = VK_MEMORY_HEAP_DEVICE_LOCAL_BIT
    static let multiInstance = VK_MEMORY_HEAP_MULTI_INSTANCE_BIT
    static let multiInstanceKhr = VK_MEMORY_HEAP_MULTI_INSTANCE_BIT_KHR
}
