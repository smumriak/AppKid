//
//  VkSharingMode.swift
//  Volcano
//
//  Created by Serhii Mumriak on 27.11.2020.
//

import CVulkan

public extension VkSharingMode {
    static let exclusive: VkSharingMode = .VK_SHARING_MODE_EXCLUSIVE
    static let concurrent: VkSharingMode = .VK_SHARING_MODE_CONCURRENT
}
