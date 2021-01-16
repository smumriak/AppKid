//
//  VkBlendFactor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkBlendFactor = CVulkan.VkBlendFactor

public extension VkBlendFactor {
    static let zero: VkBlendFactor = .VK_BLEND_FACTOR_ZERO
    static let one: VkBlendFactor = .VK_BLEND_FACTOR_ONE
    static let sourceColor: VkBlendFactor = .VK_BLEND_FACTOR_SRC_COLOR
    static let oneMinusSourceColor: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR
    static let destinationColor: VkBlendFactor = .VK_BLEND_FACTOR_DST_COLOR
    static let oneMinusDestinationColor: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR
    static let sourceAlpha: VkBlendFactor = .VK_BLEND_FACTOR_SRC_ALPHA
    static let oneMinusSourceAlpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
    static let destinationAlpha: VkBlendFactor = .VK_BLEND_FACTOR_DST_ALPHA
    static let oneMinusDestinationAlpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA
    static let constantColor: VkBlendFactor = .VK_BLEND_FACTOR_CONSTANT_COLOR
    static let oneMinusConstantColor: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR
    static let constantAlpha: VkBlendFactor = .VK_BLEND_FACTOR_CONSTANT_ALPHA
    static let oneMinusConstantAlpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA
    static let sourceAlphaSaturate: VkBlendFactor = .VK_BLEND_FACTOR_SRC_ALPHA_SATURATE
    static let source1Color: VkBlendFactor = .VK_BLEND_FACTOR_SRC1_COLOR
    static let oneMinusSource1Color: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR
    static let source1Alpha: VkBlendFactor = .VK_BLEND_FACTOR_SRC1_ALPHA
    static let oneMinusSource1Alpha: VkBlendFactor = .VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA
}
