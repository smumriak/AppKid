//
//  VkDependencyFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkDependencyFlagBits = CVulkan.VkDependencyFlagBits

public extension VkDependencyFlagBits {
    static let byRegion = VK_DEPENDENCY_BY_REGION_BIT
    static let deviceGroup = VK_DEPENDENCY_DEVICE_GROUP_BIT
    static let viewLocal = VK_DEPENDENCY_VIEW_LOCAL_BIT
    static let viewLocalKhr = VK_DEPENDENCY_VIEW_LOCAL_BIT_KHR
    static let deviceGroupKhr = VK_DEPENDENCY_DEVICE_GROUP_BIT_KHR
}
