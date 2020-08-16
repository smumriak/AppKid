//
//  VkMemoryHeapFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension VkMemoryHeapFlagBits {
    public static let deviceLocal = VK_MEMORY_HEAP_DEVICE_LOCAL_BIT
    public static let multiInstance = VK_MEMORY_HEAP_MULTI_INSTANCE_BIT
    public static let multiInstanceKhr = VK_MEMORY_HEAP_MULTI_INSTANCE_BIT_KHR
}
