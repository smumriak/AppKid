//
//  VkQueryResultFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkQueryResultFlagBits {
    static let sixtyFour = VK_QUERY_RESULT_64_BIT
    static let wait = VK_QUERY_RESULT_WAIT_BIT
    static let withAvailability = VK_QUERY_RESULT_WITH_AVAILABILITY_BIT
    static let partial = VK_QUERY_RESULT_PARTIAL_BIT
}
