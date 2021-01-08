//
//  VkComponentSwizzle.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import CVulkan

public extension VkComponentSwizzle {
    static let identity: VkComponentSwizzle = .VK_COMPONENT_SWIZZLE_IDENTITY
    static let zero: VkComponentSwizzle = .VK_COMPONENT_SWIZZLE_ZERO
    static let one: VkComponentSwizzle = .VK_COMPONENT_SWIZZLE_ONE
    static let r: VkComponentSwizzle = .VK_COMPONENT_SWIZZLE_R
    static let g: VkComponentSwizzle = .VK_COMPONENT_SWIZZLE_G
    static let b: VkComponentSwizzle = .VK_COMPONENT_SWIZZLE_B
    static let a: VkComponentSwizzle = .VK_COMPONENT_SWIZZLE_A
}

