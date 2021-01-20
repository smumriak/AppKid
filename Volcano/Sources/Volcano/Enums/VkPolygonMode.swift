//
//  VkPolygonMode.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.01.2021.
//

import CVulkan

public typealias VkPolygonMode = CVulkan.VkPolygonMode

public extension VkPolygonMode {
    static let fill: VkPolygonMode = .VK_POLYGON_MODE_FILL
    static let line: VkPolygonMode = .VK_POLYGON_MODE_LINE
    static let point: VkPolygonMode = .VK_POLYGON_MODE_POINT
    static let fillRectangleNV: VkPolygonMode = .VK_POLYGON_MODE_FILL_RECTANGLE_NV
}
