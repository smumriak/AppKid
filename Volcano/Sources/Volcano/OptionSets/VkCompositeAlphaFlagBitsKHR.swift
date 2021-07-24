//
//  VkCompositeAlphaFlagBitsKHR.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.08.2020.
//

import CVulkan

public typealias VkCompositeAlphaFlagBitsKHR = CVulkan.VkCompositeAlphaFlagBitsKHR

public extension VkCompositeAlphaFlagBitsKHR {
    static let opaque: Self = .VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
    static let preMultiplied: Self = .VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR
    static let postMultiplied: Self = .VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR
    static let inherit: Self = .VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR
}
