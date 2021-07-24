//
//  VkPrimitiveTopology.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.01.2021.
//

import CVulkan

public typealias VkPrimitiveTopology = CVulkan.VkPrimitiveTopology

public extension VkPrimitiveTopology {
    static let pointList: Self = .VK_PRIMITIVE_TOPOLOGY_POINT_LIST
    static let lineList: Self = .VK_PRIMITIVE_TOPOLOGY_LINE_LIST
    static let lineStrip: Self = .VK_PRIMITIVE_TOPOLOGY_LINE_STRIP
    static let triangleList: Self = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
    static let triangleStrip: Self = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP
    static let triangleFan: Self = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN
    static let lineListWithAdjacency: Self = .VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY
    static let lineStripWithAdjacency: Self = .VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY
    static let triangleListWithAdjacency: Self = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY
    static let triangleStripWithAdjacency: Self = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY
    static let patchList: Self = .VK_PRIMITIVE_TOPOLOGY_PATCH_LIST
}
