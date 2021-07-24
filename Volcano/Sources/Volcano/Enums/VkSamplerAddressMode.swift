//
//  VkSamplerAddressMode.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021.
//

import CVulkan

public typealias VkSamplerAddressMode = CVulkan.VkSamplerAddressMode

public extension VkSamplerAddressMode {
    static let `repeat`: Self = .VK_SAMPLER_ADDRESS_MODE_REPEAT
    static let mirroredRepeat: Self = .VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT
    static let clampToEdge: Self = .VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE
    static let clampToBorder: Self = .VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER
    static let mirrorClampToEdge: Self = .VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE
}
