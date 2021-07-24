//
//  VkImageUsageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkImageUsageFlagBits = CVulkan.VkImageUsageFlagBits

public extension VkImageUsageFlagBits {
    static let transferSource: Self = .VK_IMAGE_USAGE_TRANSFER_SRC_BIT
    static let transferDestination: Self = .VK_IMAGE_USAGE_TRANSFER_DST_BIT
    static let sampled: Self = .VK_IMAGE_USAGE_SAMPLED_BIT
    static let storage: Self = .VK_IMAGE_USAGE_STORAGE_BIT
    static let colorAttachment: Self = .VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT
    static let depthStencilAttachment: Self = .VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT
    static let transientAttachment: Self = .VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT
    static let inputAttachment: Self = .VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT
    static let shadingRateImageNv: Self = .VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV
    static let fragmentDensityMapExt: Self = .VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT
}
