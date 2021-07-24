//
//  VkSurfaceTransformFlagBitsKHR.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.08.2020.
//

import CVulkan

public typealias VkSurfaceTransformFlagBitsKHR = CVulkan.VkSurfaceTransformFlagBitsKHR

public extension VkSurfaceTransformFlagBitsKHR {
    static let identity: Self = .VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR
    static let rotate90: Self = .VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR
    static let rotate180: Self = .VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR
    static let rotate270: Self = .VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR
    static let horizontalMirror: Self = .VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_BIT_KHR
    static let horizontalMirrorRotate90: Self = .VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_90_BIT_KHR
    static let horizontalMirrorRotate180: Self = .VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_180_BIT_KHR
    static let horizontalMirrorRotate270: Self = .VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_270_BIT_KHR
    static let inherit: Self = .VK_SURFACE_TRANSFORM_INHERIT_BIT_KHR
}
