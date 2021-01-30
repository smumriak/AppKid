//
//  VkImageLayout.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public typealias VkImageLayout = CVulkan.VkImageLayout

public extension VkImageLayout {
    static let undefined = VK_IMAGE_LAYOUT_UNDEFINED
    static let general = VK_IMAGE_LAYOUT_GENERAL
    static let colorAttachmentOptimal = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    static let depthStencilAttachmentOptimal = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
    static let depthStencilReadOnlyOptimal = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL
    static let shaderReadOnlyOptimal = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
    static let transferSourceOptimal = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL
    static let transferDestinationOptimal = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
    static let preinitialized = VK_IMAGE_LAYOUT_PREINITIALIZED
    static let depthReadOnlyStencilAttachmentOptimal = VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL
    static let depthAttachmentStencilReadOnlyOptimal = VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL
    static let depthAttachmentOptimal = VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL
    static let depthReadOnlyOptimal = VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL
    static let stencilAttachmentOptimal = VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL
    static let stencilReadOnlyOptimal = VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL
    static let presentSource = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
    static let sharedPresent = VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR
    static let shadingRateOptimal = VK_IMAGE_LAYOUT_SHADING_RATE_OPTIMAL_NV
    static let fragmentDensityMapOptimalExt = VK_IMAGE_LAYOUT_FRAGMENT_DENSITY_MAP_OPTIMAL_EXT
}
