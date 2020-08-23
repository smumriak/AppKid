//
//  VkDependencyFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//


extension VkDependencyFlagBits {
    public static let byRegion = VK_DEPENDENCY_BY_REGION_BIT
    public static let deviceGroup = VK_DEPENDENCY_DEVICE_GROUP_BIT
    public static let viewLocal = VK_DEPENDENCY_VIEW_LOCAL_BIT
    public static let viewLocalKhr = VK_DEPENDENCY_VIEW_LOCAL_BIT_KHR
    public static let deviceGroupKhr = VK_DEPENDENCY_DEVICE_GROUP_BIT_KHR
}
