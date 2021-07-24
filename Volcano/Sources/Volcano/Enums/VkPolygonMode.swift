//
//  VkPolygonMode.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.01.2021.
//

import CVulkan

public typealias VkPolygonMode = CVulkan.VkPolygonMode

public extension VkPolygonMode {
    static let fill: Self = .VK_POLYGON_MODE_FILL
    static let line: Self = .VK_POLYGON_MODE_LINE
    static let point: Self = .VK_POLYGON_MODE_POINT
    static let fillRectangleNV: Self = .VK_POLYGON_MODE_FILL_RECTANGLE_NV
}
