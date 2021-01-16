//
//  VkSparseMemoryBindFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkSparseMemoryBindFlagBits = CVulkan.VkSparseMemoryBindFlagBits

public extension VkSparseMemoryBindFlagBits {
    static let metadata = VK_SPARSE_MEMORY_BIND_METADATA_BIT
}
