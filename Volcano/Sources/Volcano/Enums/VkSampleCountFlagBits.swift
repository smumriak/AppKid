//
//  VkSampleCountFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkSampleCountFlagBits = CVulkan.VkSampleCountFlagBits

public extension VkSampleCountFlagBits {
    static let one = VK_SAMPLE_COUNT_1_BIT
    static let two = VK_SAMPLE_COUNT_2_BIT
    static let four = VK_SAMPLE_COUNT_4_BIT
    static let eight = VK_SAMPLE_COUNT_8_BIT
    static let sixteen = VK_SAMPLE_COUNT_16_BIT
    static let thirtyTwo = VK_SAMPLE_COUNT_32_BIT
    static let sixtyFour = VK_SAMPLE_COUNT_64_BIT
}
