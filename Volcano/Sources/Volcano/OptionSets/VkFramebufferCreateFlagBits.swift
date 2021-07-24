//
//  VkFramebufferCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkFramebufferCreateFlagBits = CVulkan.VkFramebufferCreateFlagBits

public extension VkFramebufferCreateFlagBits {
    static let imageless: Self = .VK_FRAMEBUFFER_CREATE_IMAGELESS_BIT
    static let imagelessKhr: Self = .VK_FRAMEBUFFER_CREATE_IMAGELESS_BIT_KHR
}
