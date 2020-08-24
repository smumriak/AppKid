//
//  VkImageLayout.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

extension VkImageLayout {
    public static let undefined = VK_IMAGE_LAYOUT_UNDEFINED
    public static let general = VK_IMAGE_LAYOUT_GENERAL
    public static let colorAttachmentOptimal = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    public static let depthStencilAttachmentOptimal = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
    public static let depthStencilReadOnlyOptimal = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL
    public static let shaderReadOnlyOptimal = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
    public static let transferSourceOptimal = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL
    public static let transferDestinationOptimal = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
    public static let preinitialized = VK_IMAGE_LAYOUT_PREINITIALIZED
    public static let depthReadOnlyStencilAttachmentOptimal = VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL
    public static let depthAttachmentStencilReadOnlyOptimal = VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL
    public static let depthAttachmentOptimal = VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL
    public static let depthReadOnlyOptimal = VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL
    public static let stencilAttachmentOptimal = VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL
    public static let stencilReadOnlyOptimal = VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL
    public static let presentSource = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
    public static let sharedPresent = VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR
    public static let shadingRateOptimal = VK_IMAGE_LAYOUT_SHADING_RATE_OPTIMAL_NV
    public static let fragmentDensityMapOptimalExt = VK_IMAGE_LAYOUT_FRAGMENT_DENSITY_MAP_OPTIMAL_EXT
    public static let depthReadOnlyStencilAttachmentOptimalKHR = VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL_KHR
    public static let depthAttachmentStencilReadOnlyOptimalKHR = VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL_KHR
    public static let depthAttachmentOptimalKHR = VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL_KHR
    public static let depthReadOnlyOptimalKHR = VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL_KHR
    public static let stencilAttachmentOptimalKHR = VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL_KHR
    public static let stencilReadOnlyOptimalKHR = VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL_KHR
}
