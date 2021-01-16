//
//  VkQueryControlFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkQueryControlFlagBits = CVulkan.VkQueryControlFlagBits

public extension VkQueryControlFlagBits {
    static let precise = VK_QUERY_CONTROL_PRECISE_BIT
}
