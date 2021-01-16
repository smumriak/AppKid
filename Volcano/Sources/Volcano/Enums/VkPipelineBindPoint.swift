//
//  VkPipelineBindPoint.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkPipelineBindPoint = CVulkan.VkPipelineBindPoint

public extension VkPipelineBindPoint {
    static let graphics: VkPipelineBindPoint = .VK_PIPELINE_BIND_POINT_GRAPHICS
    static let compute: VkPipelineBindPoint = .VK_PIPELINE_BIND_POINT_COMPUTE
    static let rayTracingKhr: VkPipelineBindPoint = .VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR
    static let rayTracingNv: VkPipelineBindPoint = .VK_PIPELINE_BIND_POINT_RAY_TRACING_NV
}
