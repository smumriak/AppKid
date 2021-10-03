//
//  VkMemoryPropertyFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkMemoryPropertyFlagBits = CVulkan.VkMemoryPropertyFlagBits

public extension VkMemoryPropertyFlagBits {
    static let deviceLocal: Self = .VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT
    static let hostVisible: Self = .VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
    static let hostCoherent: Self = .VK_MEMORY_PROPERTY_HOST_COHERENT_BIT
    static let hostCached: Self = .VK_MEMORY_PROPERTY_HOST_CACHED_BIT
    static let lazilyAllocated: Self = .VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT
    static let protected: Self = .VK_MEMORY_PROPERTY_PROTECTED_BIT
    static let deviceCoherentAmd: Self = .VK_MEMORY_PROPERTY_DEVICE_COHERENT_BIT_AMD
    static let deviceUncachedAmd: Self = .VK_MEMORY_PROPERTY_DEVICE_UNCACHED_BIT_AMD
    static let rdmaCapableBitNv: Self = .VK_MEMORY_PROPERTY_RDMA_CAPABLE_BIT_NV
}
