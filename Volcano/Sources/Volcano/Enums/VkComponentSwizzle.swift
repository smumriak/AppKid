//
//  VkComponentSwizzle.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import CVulkan

public typealias VkComponentSwizzle = CVulkan.VkComponentSwizzle

public extension VkComponentSwizzle {
    static let identity: Self = .VK_COMPONENT_SWIZZLE_IDENTITY
    static let zero: Self = .VK_COMPONENT_SWIZZLE_ZERO
    static let one: Self = .VK_COMPONENT_SWIZZLE_ONE
    static let r: Self = .VK_COMPONENT_SWIZZLE_R
    static let g: Self = .VK_COMPONENT_SWIZZLE_G
    static let b: Self = .VK_COMPONENT_SWIZZLE_B
    static let a: Self = .VK_COMPONENT_SWIZZLE_A
}
