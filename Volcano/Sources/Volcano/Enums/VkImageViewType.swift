//
//  VkImageViewType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import CVulkan

public extension VkImageViewType {
    static let type1D: VkImageViewType = .VK_IMAGE_VIEW_TYPE_1D
    static let type2D: VkImageViewType = .VK_IMAGE_VIEW_TYPE_2D
    static let type3D: VkImageViewType = .VK_IMAGE_VIEW_TYPE_3D
    static let typeCube: VkImageViewType = .VK_IMAGE_VIEW_TYPE_CUBE
    static let type1DArray: VkImageViewType = .VK_IMAGE_VIEW_TYPE_1D_ARRAY
    static let type2DArray: VkImageViewType = .VK_IMAGE_VIEW_TYPE_2D_ARRAY
    static let typeCubeArray: VkImageViewType = .VK_IMAGE_VIEW_TYPE_CUBE_ARRAY
}
