//
//  VkImageType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import CVulkan

public typealias VkImageTiling = CVulkan.VkImageTiling

public extension VkImageTiling {
    static let optimal: Self = .VK_IMAGE_TILING_OPTIMAL
    static let linear: Self = .VK_IMAGE_TILING_LINEAR
    static let drmFormatModifierEXT: Self = .VK_IMAGE_TILING_DRM_FORMAT_MODIFIER_EXT
}
