//
//  VkSamplerCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkSamplerCreateFlagBits = CVulkan.VkSamplerCreateFlagBits

public extension VkSamplerCreateFlagBits {
    static let subsampledExt: Self = .VK_SAMPLER_CREATE_SUBSAMPLED_BIT_EXT
    static let subsampledCoarseReconstructionExt: Self = .VK_SAMPLER_CREATE_SUBSAMPLED_COARSE_RECONSTRUCTION_BIT_EXT
}
