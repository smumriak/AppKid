//
//  VkCompositeAlphaFlagBitsKHR.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.08.2020.
//

import CVulkan

extension VkCompositeAlphaFlagBitsKHR {
    public static let opaque = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
    public static let preMultiplied = VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR
    public static let postMultiplied = VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR
    public static let inherit = VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR
}
