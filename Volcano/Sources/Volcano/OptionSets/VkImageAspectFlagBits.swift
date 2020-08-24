//
//  VkImageAspectFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension VkImageAspectFlagBits {
    public static let color = VK_IMAGE_ASPECT_COLOR_BIT
    public static let depth = VK_IMAGE_ASPECT_DEPTH_BIT
    public static let stencil = VK_IMAGE_ASPECT_STENCIL_BIT
    public static let metadata = VK_IMAGE_ASPECT_METADATA_BIT
    public static let plane0 = VK_IMAGE_ASPECT_PLANE_0_BIT
    public static let plane1 = VK_IMAGE_ASPECT_PLANE_1_BIT
    public static let plane2 = VK_IMAGE_ASPECT_PLANE_2_BIT
    public static let memoryPlane0Ext = VK_IMAGE_ASPECT_MEMORY_PLANE_0_BIT_EXT
    public static let memoryPlane1Ext = VK_IMAGE_ASPECT_MEMORY_PLANE_1_BIT_EXT
    public static let memoryPlane2Ext = VK_IMAGE_ASPECT_MEMORY_PLANE_2_BIT_EXT
    public static let memoryPlane3Ext = VK_IMAGE_ASPECT_MEMORY_PLANE_3_BIT_EXT
    public static let plane0Khr = VK_IMAGE_ASPECT_PLANE_0_BIT_KHR
    public static let plane1Khr = VK_IMAGE_ASPECT_PLANE_1_BIT_KHR
    public static let plane2Khr = VK_IMAGE_ASPECT_PLANE_2_BIT_KHR
}
