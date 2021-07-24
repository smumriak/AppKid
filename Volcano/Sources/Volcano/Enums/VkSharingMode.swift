//
//  VkSharingMode.swift
//  Volcano
//
//  Created by Serhii Mumriak on 27.11.2020.
//

import CVulkan

public typealias VkSharingMode = CVulkan.VkSharingMode

public extension VkSharingMode {
    static let exclusive: Self = .VK_SHARING_MODE_EXCLUSIVE
    static let concurrent: Self = .VK_SHARING_MODE_CONCURRENT
}
