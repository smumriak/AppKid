//
//  VkQueryPipelineStatisticFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkQueryPipelineStatisticFlagBits = CVulkan.VkQueryPipelineStatisticFlagBits

public extension VkQueryPipelineStatisticFlagBits {
    static let inputAssemblyVertices: Self = .VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_VERTICES_BIT
    static let inputAssemblyPrimitives: Self = .VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_PRIMITIVES_BIT
    static let vertexShaderInvocations: Self = .VK_QUERY_PIPELINE_STATISTIC_VERTEX_SHADER_INVOCATIONS_BIT
    static let geometryShaderInvocations: Self = .VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_INVOCATIONS_BIT
    static let geometryShaderPrimitives: Self = .VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_PRIMITIVES_BIT
    static let clippingInvocations: Self = .VK_QUERY_PIPELINE_STATISTIC_CLIPPING_INVOCATIONS_BIT
    static let clippingPrimitives: Self = .VK_QUERY_PIPELINE_STATISTIC_CLIPPING_PRIMITIVES_BIT
    static let fragmentShaderInvocations: Self = .VK_QUERY_PIPELINE_STATISTIC_FRAGMENT_SHADER_INVOCATIONS_BIT
    static let tessellationControlShaderPatches: Self = .VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_CONTROL_SHADER_PATCHES_BIT
    static let tessellationEvaluationShaderInvocations: Self = .VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_EVALUATION_SHADER_INVOCATIONS_BIT
    static let computeShaderInvocations: Self = .VK_QUERY_PIPELINE_STATISTIC_COMPUTE_SHADER_INVOCATIONS_BIT
}
