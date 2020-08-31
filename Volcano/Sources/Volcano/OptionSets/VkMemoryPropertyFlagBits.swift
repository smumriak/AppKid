//
//  VkMemoryPropertyFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkMemoryPropertyFlagBits {
    static let deviceLocal = VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT
    static let hostVisible = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
    static let hostCoherent = VK_MEMORY_PROPERTY_HOST_COHERENT_BIT
    static let hostCached = VK_MEMORY_PROPERTY_HOST_CACHED_BIT
    static let lazilyAllocated = VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT
    static let protected = VK_MEMORY_PROPERTY_PROTECTED_BIT
    static let deviceCoherentAmd = VK_MEMORY_PROPERTY_DEVICE_COHERENT_BIT_AMD
    static let deviceUncachedAmd = VK_MEMORY_PROPERTY_DEVICE_UNCACHED_BIT_AMD
}
