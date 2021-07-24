//
//  VkDescriptorType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 25.12.2020.
//

import CVulkan

public typealias VkDescriptorType = CVulkan.VkDescriptorType

public extension VkDescriptorType {
    static let sampler: Self = .VK_DESCRIPTOR_TYPE_SAMPLER
    static let combinedImageSampler: Self = .VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER
    static let sampledImage: Self = .VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE
    static let storageImage: Self = .VK_DESCRIPTOR_TYPE_STORAGE_IMAGE
    static let uniformTexelBuffer: Self = .VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER
    static let storageTexelBuffer: Self = .VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER
    static let uniformBuffer: Self = .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
    static let storageBuffer: Self = .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER
    static let uniformBufferDynamic: Self = .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC
    static let storageBufferDynamic: Self = .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC
    static let inputAttachment: Self = .VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT
    static let inlineUniformblockEXT: Self = .VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK_EXT
    static let accelerationStructureKHR: Self = .VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR
    static let accelerationStructureNV: Self = .VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV
}
