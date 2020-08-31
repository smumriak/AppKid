//
//  VkCompositeAlphaFlagBitsKHR.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.08.2020.
//

import CVulkan

public extension VkCompositeAlphaFlagBitsKHR {
    static let opaque = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
    static let preMultiplied = VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR
    static let postMultiplied = VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR
    static let inherit = VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR
}
