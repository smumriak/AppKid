//
//  VkPipelineCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkPipelineCreateFlagBits = CVulkan.VkPipelineCreateFlagBits

public extension VkPipelineCreateFlagBits {
    static let disableOptimization = VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT
    static let allowDerivatives = VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT
    static let derivative = VK_PIPELINE_CREATE_DERIVATIVE_BIT
    static let viewIndexFromDeviceIndex = VK_PIPELINE_CREATE_VIEW_INDEX_FROM_DEVICE_INDEX_BIT
    static let dispatchBase = VK_PIPELINE_CREATE_DISPATCH_BASE_BIT
    static let rayTracingNoNullAnyHitShadersKhr = VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR
    static let rayTracingNoNullClosestHitShadersKhr = VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR
    static let rayTracingNoNullMissShadersKhr = VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR
    static let rayTracingNoNullIntersectionShadersKhr = VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR
    static let rayTracingSkipTrianglesKhr = VK_PIPELINE_CREATE_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR
    static let rayTracingSkipAabbsKhr = VK_PIPELINE_CREATE_RAY_TRACING_SKIP_AABBS_BIT_KHR
    static let deferCompileNv = VK_PIPELINE_CREATE_DEFER_COMPILE_BIT_NV
    static let captureStatisticsKhr = VK_PIPELINE_CREATE_CAPTURE_STATISTICS_BIT_KHR
    static let captureInternalRepresentationsKhr = VK_PIPELINE_CREATE_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR
    static let indirectBindableNv = VK_PIPELINE_CREATE_INDIRECT_BINDABLE_BIT_NV
    static let libraryKhr = VK_PIPELINE_CREATE_LIBRARY_BIT_KHR
    static let failOnPipelineCompileRequiredExt = VK_PIPELINE_CREATE_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT_EXT
    static let earlyReturnOnFailureExt = VK_PIPELINE_CREATE_EARLY_RETURN_ON_FAILURE_BIT_EXT
    static let viewIndexFromDeviceIndexKhr = VK_PIPELINE_CREATE_VIEW_INDEX_FROM_DEVICE_INDEX_BIT_KHR
    static let dispatchBaseKhr = VK_PIPELINE_CREATE_DISPATCH_BASE_KHR
}
