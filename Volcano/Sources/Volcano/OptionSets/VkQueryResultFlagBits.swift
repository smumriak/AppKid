//
//  VkQueryResultFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkQueryResultFlagBits = CVulkan.VkQueryResultFlagBits

public extension VkQueryResultFlagBits {
    static let sixtyFour: Self = .VK_QUERY_RESULT_64_BIT
    static let wait: Self = .VK_QUERY_RESULT_WAIT_BIT
    static let withAvailability: Self = .VK_QUERY_RESULT_WITH_AVAILABILITY_BIT
    static let partial: Self = .VK_QUERY_RESULT_PARTIAL_BIT
}
