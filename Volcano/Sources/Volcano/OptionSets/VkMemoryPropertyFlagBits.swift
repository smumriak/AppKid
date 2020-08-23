//
//  VkMemoryPropertyFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//


extension VkMemoryPropertyFlagBits {
    public static let deviceLocal = VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT
    public static let hostVisible = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
    public static let hostCoherent = VK_MEMORY_PROPERTY_HOST_COHERENT_BIT
    public static let hostCached = VK_MEMORY_PROPERTY_HOST_CACHED_BIT
    public static let lazilyAllocated = VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT
    public static let protected = VK_MEMORY_PROPERTY_PROTECTED_BIT
    public static let deviceCoherentAmd = VK_MEMORY_PROPERTY_DEVICE_COHERENT_BIT_AMD
    public static let deviceUncachedAmd = VK_MEMORY_PROPERTY_DEVICE_UNCACHED_BIT_AMD
}
