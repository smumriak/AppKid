//
//  VkImageViewCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkImageViewCreateFlagBits = CVulkan.VkImageViewCreateFlagBits

public extension VkImageViewCreateFlagBits {
    static let fragmentDensityMapDynamicExt: Self = .VK_IMAGE_VIEW_CREATE_FRAGMENT_DENSITY_MAP_DYNAMIC_BIT_EXT
}
