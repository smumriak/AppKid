//
//  VkFilter.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021
//

import CVulkan

public typealias VkFilter = CVulkan.VkFilter

public extension VkFilter {
    static let nearest: Self = .VK_FILTER_NEAREST
    static let linear: Self = .VK_FILTER_LINEAR
    static let cubic: Self = .VK_FILTER_CUBIC_IMG
}
