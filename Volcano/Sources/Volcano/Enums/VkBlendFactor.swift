//
//  VkBlendFactor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkBlendFactor = CVulkan.VkBlendFactor

public extension VkBlendFactor {
    static let zero: Self = .VK_BLEND_FACTOR_ZERO
    static let one: Self = .VK_BLEND_FACTOR_ONE
    static let sourceColor: Self = .VK_BLEND_FACTOR_SRC_COLOR
    static let oneMinusSourceColor: Self = .VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR
    static let destinationColor: Self = .VK_BLEND_FACTOR_DST_COLOR
    static let oneMinusDestinationColor: Self = .VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR
    static let sourceAlpha: Self = .VK_BLEND_FACTOR_SRC_ALPHA
    static let oneMinusSourceAlpha: Self = .VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
    static let destinationAlpha: Self = .VK_BLEND_FACTOR_DST_ALPHA
    static let oneMinusDestinationAlpha: Self = .VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA
    static let constantColor: Self = .VK_BLEND_FACTOR_CONSTANT_COLOR
    static let oneMinusConstantColor: Self = .VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR
    static let constantAlpha: Self = .VK_BLEND_FACTOR_CONSTANT_ALPHA
    static let oneMinusConstantAlpha: Self = .VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA
    static let sourceAlphaSaturate: Self = .VK_BLEND_FACTOR_SRC_ALPHA_SATURATE
    static let source1Color: Self = .VK_BLEND_FACTOR_SRC1_COLOR
    static let oneMinusSource1Color: Self = .VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR
    static let source1Alpha: Self = .VK_BLEND_FACTOR_SRC1_ALPHA
    static let oneMinusSource1Alpha: Self = .VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA
}
