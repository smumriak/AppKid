//
//  VkSubpassDescriptionFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkSubpassDescriptionFlagBits = CVulkan.VkSubpassDescriptionFlagBits

public extension VkSubpassDescriptionFlagBits {
    static let perViewAttributesNvx = VK_SUBPASS_DESCRIPTION_PER_VIEW_ATTRIBUTES_BIT_NVX
    static let perViewPositionXOnlyNvx = VK_SUBPASS_DESCRIPTION_PER_VIEW_POSITION_X_ONLY_BIT_NVX
    static let fragmentRegionQcom = VK_SUBPASS_DESCRIPTION_FRAGMENT_REGION_BIT_QCOM
    static let shaderResolveQcom = VK_SUBPASS_DESCRIPTION_SHADER_RESOLVE_BIT_QCOM
}
