//
//  VkIndexType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 07.12.2020.
//

import CVulkan 

public typealias VkIndexType = CVulkan.VkIndexType

public extension VkIndexType {
    static let uint16: VkIndexType = .VK_INDEX_TYPE_UINT16
    static let uint32: VkIndexType = .VK_INDEX_TYPE_UINT32
    static let noneKHR: VkIndexType = .VK_INDEX_TYPE_NONE_KHR
    static let uint8EXT: VkIndexType = .VK_INDEX_TYPE_UINT8_EXT
    static let noneNV: VkIndexType = .VK_INDEX_TYPE_NONE_NV
}