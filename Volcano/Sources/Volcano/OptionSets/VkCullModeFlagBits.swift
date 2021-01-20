//
//  VkCullModeFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkCullModeFlagBits = CVulkan.VkCullModeFlagBits

public extension VkCullModeFlagBits {
    static let front = VK_CULL_MODE_FRONT_BIT
    static let back = VK_CULL_MODE_BACK_BIT
    static let frontAndBack = VK_CULL_MODE_FRONT_AND_BACK
}
