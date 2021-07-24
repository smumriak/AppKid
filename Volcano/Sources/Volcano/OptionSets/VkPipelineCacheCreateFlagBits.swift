//
//  VkPipelineCacheCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkPipelineCacheCreateFlagBits = CVulkan.VkPipelineCacheCreateFlagBits

public extension VkPipelineCacheCreateFlagBits {
    static let externallySynchronizedExt: Self = .VK_PIPELINE_CACHE_CREATE_EXTERNALLY_SYNCHRONIZED_BIT_EXT
}
