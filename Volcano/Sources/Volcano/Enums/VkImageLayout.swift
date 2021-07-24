//
//  VkImageLayout.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public typealias VkImageLayout = CVulkan.VkImageLayout

public extension VkImageLayout {
    static let undefined: Self = .VK_IMAGE_LAYOUT_UNDEFINED
    static let general: Self = .VK_IMAGE_LAYOUT_GENERAL
    static let colorAttachmentOptimal: Self = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    static let depthStencilAttachmentOptimal: Self = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
    static let depthStencilReadOnlyOptimal: Self = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL
    static let shaderReadOnlyOptimal: Self = .VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
    static let transferSourceOptimal: Self = .VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL
    static let transferDestinationOptimal: Self = .VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
    static let preinitialized: Self = .VK_IMAGE_LAYOUT_PREINITIALIZED
    static let depthReadOnlyStencilAttachmentOptimal: Self = .VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL
    static let depthAttachmentStencilReadOnlyOptimal: Self = .VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL
    static let depthAttachmentOptimal: Self = .VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL
    static let depthReadOnlyOptimal: Self = .VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL
    static let stencilAttachmentOptimal: Self = .VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL
    static let stencilReadOnlyOptimal: Self = .VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL
    static let presentSource: Self = .VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
    static let sharedPresent: Self = .VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR
    static let shadingRateOptimal: Self = .VK_IMAGE_LAYOUT_SHADING_RATE_OPTIMAL_NV
    static let fragmentDensityMapOptimalExt: Self = .VK_IMAGE_LAYOUT_FRAGMENT_DENSITY_MAP_OPTIMAL_EXT
}
