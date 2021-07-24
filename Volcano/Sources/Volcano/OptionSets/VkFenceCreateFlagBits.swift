//
//  VkFenceCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkFenceCreateFlagBits = CVulkan.VkFenceCreateFlagBits

public extension VkFenceCreateFlagBits {
    static let signaled: Self = .VK_FENCE_CREATE_SIGNALED_BIT
}
