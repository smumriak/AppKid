//
//  VkImageType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import CVulkan

public typealias VkImageType = CVulkan.VkImageType

public extension VkImageType {
    static let type1D: Self = .VK_IMAGE_TYPE_1D
    static let type2D: Self = .VK_IMAGE_TYPE_2D
    static let type3D: Self = .VK_IMAGE_TYPE_3D
}
