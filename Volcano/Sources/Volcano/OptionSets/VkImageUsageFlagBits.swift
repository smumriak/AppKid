//
//  VkImageUsageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//


extension VkImageUsageFlagBits {
    public static let transferSrc = VK_IMAGE_USAGE_TRANSFER_SRC_BIT
    public static let transferDst = VK_IMAGE_USAGE_TRANSFER_DST_BIT
    public static let sampled = VK_IMAGE_USAGE_SAMPLED_BIT
    public static let storage = VK_IMAGE_USAGE_STORAGE_BIT
    public static let colorAttachment = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT
    public static let depthStencilAttachment = VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT
    public static let transientAttachment = VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT
    public static let inputAttachment = VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT
    public static let shadingRateImageNv = VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV
    public static let fragmentDensityMapExt = VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT
}
