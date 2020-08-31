//
//  VkBlendFactor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

extension VkBlendFactor {
    public static let zero: VkBlendFactor = .VK_BLEND_FACTOR_ZERO
    public static let one: VkBlendFactor = .VK_BLEND_FACTOR_ONE
    public static let sourceColor: VkBlendFactor = .VK_BLEND_FACTOR_SRC_COLOR
    public static let oneMinusSourceColor: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR
    public static let destinationColor: VkBlendFactor = .VK_BLEND_FACTOR_DST_COLOR
    public static let oneMinusDestinationColor: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR
    public static let sourceAlpha: VkBlendFactor = .VK_BLEND_FACTOR_SRC_ALPHA
    public static let oneMinusSourceAlpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
    public static let destinationAlpha: VkBlendFactor = .VK_BLEND_FACTOR_DST_ALPHA
    public static let oneMinusDestinationAlpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA
    public static let constantColor: VkBlendFactor = .VK_BLEND_FACTOR_CONSTANT_COLOR
    public static let oneMinusConstantColor: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR
    public static let constantAlpha: VkBlendFactor = .VK_BLEND_FACTOR_CONSTANT_ALPHA
    public static let oneMinusConstantAlpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA
    public static let sourceAlphaSaturate: VkBlendFactor = .VK_BLEND_FACTOR_SRC_ALPHA_SATURATE
    public static let source1Color: VkBlendFactor = .VK_BLEND_FACTOR_SRC1_COLOR
    public static let oneMinusSource1Color: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR
    public static let source1Alpha: VkBlendFactor = .VK_BLEND_FACTOR_SRC1_ALPHA
    public static let oneMinusSource1Alpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA
}
