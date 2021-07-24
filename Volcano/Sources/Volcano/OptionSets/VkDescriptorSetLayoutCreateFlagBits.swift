//
//  VkDescriptorSetLayoutCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkDescriptorSetLayoutCreateFlagBits = CVulkan.VkDescriptorSetLayoutCreateFlagBits

public extension VkDescriptorSetLayoutCreateFlagBits {
    static let updateAfterBindPool: Self = .VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT
    static let pushDescriptorKhr: Self = .VK_DESCRIPTOR_SET_LAYOUT_CREATE_PUSH_DESCRIPTOR_BIT_KHR
    static let updateAfterBindPoolExt: Self = .VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT_EXT
}
