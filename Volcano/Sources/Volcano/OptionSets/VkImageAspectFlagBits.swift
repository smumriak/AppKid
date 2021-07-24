//
//  VkImageAspectFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkImageAspectFlagBits = CVulkan.VkImageAspectFlagBits

public extension VkImageAspectFlagBits {
    static let color: Self = .VK_IMAGE_ASPECT_COLOR_BIT
    static let depth: Self = .VK_IMAGE_ASPECT_DEPTH_BIT
    static let stencil: Self = .VK_IMAGE_ASPECT_STENCIL_BIT
    static let metadata: Self = .VK_IMAGE_ASPECT_METADATA_BIT
    static let plane0: Self = .VK_IMAGE_ASPECT_PLANE_0_BIT
    static let plane1: Self = .VK_IMAGE_ASPECT_PLANE_1_BIT
    static let plane2: Self = .VK_IMAGE_ASPECT_PLANE_2_BIT
    static let memoryPlane0Ext: Self = .VK_IMAGE_ASPECT_MEMORY_PLANE_0_BIT_EXT
    static let memoryPlane1Ext: Self = .VK_IMAGE_ASPECT_MEMORY_PLANE_1_BIT_EXT
    static let memoryPlane2Ext: Self = .VK_IMAGE_ASPECT_MEMORY_PLANE_2_BIT_EXT
    static let memoryPlane3Ext: Self = .VK_IMAGE_ASPECT_MEMORY_PLANE_3_BIT_EXT
    static let plane0Khr: Self = .VK_IMAGE_ASPECT_PLANE_0_BIT_KHR
    static let plane1Khr: Self = .VK_IMAGE_ASPECT_PLANE_1_BIT_KHR
    static let plane2Khr: Self = .VK_IMAGE_ASPECT_PLANE_2_BIT_KHR
}
