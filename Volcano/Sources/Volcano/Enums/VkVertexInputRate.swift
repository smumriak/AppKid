//
//  VkVertexInputRate.swift
//  Volcano
//
//  Created by Serhii Mumriak on 26.11.2020.
//

import CVulkan

public typealias VkVertexInputRate = CVulkan.VkVertexInputRate

public extension VkVertexInputRate {
    static let vertex: VkVertexInputRate = .VK_VERTEX_INPUT_RATE_VERTEX
    static let instance: VkVertexInputRate = .VK_VERTEX_INPUT_RATE_INSTANCE
    static let maxEnum: VkVertexInputRate = .VK_VERTEX_INPUT_RATE_MAX_ENUM
}
