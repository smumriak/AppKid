//
//  VkDescriptorType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 25.12.2020.
//

import CVulkan

public typealias VkDescriptorType = CVulkan.VkDescriptorType

public extension VkDescriptorType {
    static let sampler: VkDescriptorType = .VK_DESCRIPTOR_TYPE_SAMPLER
    static let combinedImageSampler: VkDescriptorType = .VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER
    static let sampledImage: VkDescriptorType = .VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE
    static let storageImage: VkDescriptorType = .VK_DESCRIPTOR_TYPE_STORAGE_IMAGE
    static let uniformTexelBuffer: VkDescriptorType = .VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER
    static let storageTexelBuffer: VkDescriptorType = .VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER
    static let uniformBuffer: VkDescriptorType = .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
    static let storageBuffer: VkDescriptorType = .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER
    static let uniformBufferDynamic: VkDescriptorType = .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC
    static let storageBufferDynamic: VkDescriptorType = .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC
    static let inputAttachment: VkDescriptorType = .VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT
    static let inlineUniformblockEXT: VkDescriptorType = .VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK_EXT
    static let accelerationStructureKHR: VkDescriptorType = .VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR
    static let accelerationStructureNV: VkDescriptorType = .VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV
}
