//
//  VkPipelineBindPoint.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkPipelineBindPoint = CVulkan.VkPipelineBindPoint

public extension VkPipelineBindPoint {
    static let graphics: Self = .VK_PIPELINE_BIND_POINT_GRAPHICS
    static let compute: Self = .VK_PIPELINE_BIND_POINT_COMPUTE
    static let rayTracingKhr: Self = .VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR
    static let rayTracingNv: Self = .VK_PIPELINE_BIND_POINT_RAY_TRACING_NV
}
