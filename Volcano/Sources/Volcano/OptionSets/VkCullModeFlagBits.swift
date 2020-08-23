//
//  VkCullModeFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//


extension VkCullModeFlagBits {
    public static let none = VkCullModeFlagBits()
    public static let front = VK_CULL_MODE_FRONT_BIT
    public static let back = VK_CULL_MODE_BACK_BIT
    public static let frontAndBack = VK_CULL_MODE_FRONT_AND_BACK
}
