//
//  VkQueryPipelineStatisticFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkQueryPipelineStatisticFlagBits = CVulkan.VkQueryPipelineStatisticFlagBits

public extension VkQueryPipelineStatisticFlagBits {
    static let inputAssemblyVertices = VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_VERTICES_BIT
    static let inputAssemblyPrimitives = VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_PRIMITIVES_BIT
    static let vertexShaderInvocations = VK_QUERY_PIPELINE_STATISTIC_VERTEX_SHADER_INVOCATIONS_BIT
    static let geometryShaderInvocations = VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_INVOCATIONS_BIT
    static let geometryShaderPrimitives = VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_PRIMITIVES_BIT
    static let clippingInvocations = VK_QUERY_PIPELINE_STATISTIC_CLIPPING_INVOCATIONS_BIT
    static let clippingPrimitives = VK_QUERY_PIPELINE_STATISTIC_CLIPPING_PRIMITIVES_BIT
    static let fragmentShaderInvocations = VK_QUERY_PIPELINE_STATISTIC_FRAGMENT_SHADER_INVOCATIONS_BIT
    static let tessellationControlShaderPatches = VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_CONTROL_SHADER_PATCHES_BIT
    static let tessellationEvaluationShaderInvocations = VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_EVALUATION_SHADER_INVOCATIONS_BIT
    static let computeShaderInvocations = VK_QUERY_PIPELINE_STATISTIC_COMPUTE_SHADER_INVOCATIONS_BIT
}
