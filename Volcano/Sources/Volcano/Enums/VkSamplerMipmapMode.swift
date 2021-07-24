//
//  VkSamplerMipmapMode.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021.
//

import CVulkan

public typealias VkSamplerMipmapMode = CVulkan.VkSamplerMipmapMode

public extension VkSamplerMipmapMode {
    static let nearest: Self = .VK_SAMPLER_MIPMAP_MODE_NEAREST
    static let linear: Self = .VK_SAMPLER_MIPMAP_MODE_LINEAR
}
