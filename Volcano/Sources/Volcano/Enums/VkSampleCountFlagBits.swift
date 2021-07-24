//
//  VkSampleCountFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkSampleCountFlagBits = CVulkan.VkSampleCountFlagBits

public extension VkSampleCountFlagBits {
    static let one: Self = .VK_SAMPLE_COUNT_1_BIT
    static let two: Self = .VK_SAMPLE_COUNT_2_BIT
    static let four: Self = .VK_SAMPLE_COUNT_4_BIT
    static let eight: Self = .VK_SAMPLE_COUNT_8_BIT
    static let sixteen: Self = .VK_SAMPLE_COUNT_16_BIT
    static let thirtyTwo: Self = .VK_SAMPLE_COUNT_32_BIT
    static let sixtyFour: Self = .VK_SAMPLE_COUNT_64_BIT
}
