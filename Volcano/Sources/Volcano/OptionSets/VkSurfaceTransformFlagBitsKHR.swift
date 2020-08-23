//
//  VkSurfaceTransformFlagBitsKHR.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.08.2020.
//


extension VkSurfaceTransformFlagBitsKHR {
    public static let identity = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR
    public static let rotate90 = VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR
    public static let rotate180 = VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR
    public static let rotate270 = VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR
    public static let horizontalMirror = VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_BIT_KHR
    public static let horizontalMirrorRotate90 = VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_90_BIT_KHR
    public static let horizontalMirrorRotate180 = VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_180_BIT_KHR
    public static let horizontalMirrorRotate270 = VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_270_BIT_KHR
    public static let inherit = VK_SURFACE_TRANSFORM_INHERIT_BIT_KHR
}
