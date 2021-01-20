//
//  VkPrimitiveTopology.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.01.2021.
//

import CVulkan

public typealias VkPrimitiveTopology = CVulkan.VkPrimitiveTopology

public extension VkPrimitiveTopology {
    static let pointList: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_POINT_LIST
    static let lineList: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_LINE_LIST
    static let lineStrip: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_LINE_STRIP
    static let triangleList: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
    static let triangleStrip: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP
    static let triangleFan: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN
    static let lineListWithAdjacency: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY
    static let lineStripWithAdjacency: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY
    static let triangleListWithAdjacency: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY
    static let triangleStripWithAdjacency: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY
    static let patchList: VkPrimitiveTopology = .VK_PRIMITIVE_TOPOLOGY_PATCH_LIST
}
