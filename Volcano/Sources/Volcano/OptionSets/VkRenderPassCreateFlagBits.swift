//
//  VkRenderPassCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkRenderPassCreateFlagBits = CVulkan.VkRenderPassCreateFlagBits

public extension VkRenderPassCreateFlagBits {
    static let transformQcom = VK_RENDER_PASS_CREATE_TRANSFORM_BIT_QCOM
}
