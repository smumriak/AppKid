//
//  VkDynamicState.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkDynamicState = CVulkan.VkDynamicState

public extension VkDynamicState {
    static let viewport: Self = .VK_DYNAMIC_STATE_VIEWPORT
    static let scissor: Self = .VK_DYNAMIC_STATE_SCISSOR
    static let lineWidth: Self = .VK_DYNAMIC_STATE_LINE_WIDTH
    static let depthBias: Self = .VK_DYNAMIC_STATE_DEPTH_BIAS
    static let blendConstants: Self = .VK_DYNAMIC_STATE_BLEND_CONSTANTS
    static let depthBounds: Self = .VK_DYNAMIC_STATE_DEPTH_BOUNDS
    static let stencilCompareMask: Self = .VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK
    static let stencilWriteMask: Self = .VK_DYNAMIC_STATE_STENCIL_WRITE_MASK
    static let stencilReference: Self = .VK_DYNAMIC_STATE_STENCIL_REFERENCE
    static let viewportWScalingNV: Self = .VK_DYNAMIC_STATE_VIEWPORT_W_SCALING_NV
    static let discardRectangleEXT: Self = .VK_DYNAMIC_STATE_DISCARD_RECTANGLE_EXT
    static let sampleLocationsEXT: Self = .VK_DYNAMIC_STATE_SAMPLE_LOCATIONS_EXT
    static let viewportShadingRatePaletteNV: Self = .VK_DYNAMIC_STATE_VIEWPORT_SHADING_RATE_PALETTE_NV
    static let viewportCoarseSampleOrderNV: Self = .VK_DYNAMIC_STATE_VIEWPORT_COARSE_SAMPLE_ORDER_NV
    static let exclusiveScissorNV: Self = .VK_DYNAMIC_STATE_EXCLUSIVE_SCISSOR_NV
    static let lineStippleEXT: Self = .VK_DYNAMIC_STATE_LINE_STIPPLE_EXT
    
    // static let rayRracingPipelineStackSizeKHR: Self = .VK_DYNAMIC_STATE_RAY_TRACING_PIPELINE_STACK_SIZE_KHR
    
    #if !os(macOS)
        // static let cullModeExt: Self = .VK_DYNAMIC_STATE_CULL_MODE_EXT
        // static let frontFaceExt: Self = .VK_DYNAMIC_STATE_FRONT_FACE_EXT
        // static let primitiveTopologyExt: Self = .VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY_EXT
        // static let viewportWithCountExt: Self = .VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT_EXT
        // static let scissorWithCountExt: Self = .VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT_EXT
        // static let vertexInputBindingStrideExt: Self = .VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE_EXT
        // static let depthTestEnableExt: Self = .VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE_EXT
        // static let depthWriteEnableExt: Self = .VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE_EXT
        // static let depthCompareOperationExt: Self = .VK_DYNAMIC_STATE_DEPTH_COMPARE_OP_EXT
        // static let depthBoundsTestEnableExt: Self = .VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE_EXT
        // static let stencilTestEnableExt: Self = .VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE_EXT
        // static let stencilOperationExt: Self = .VK_DYNAMIC_STATE_STENCIL_OP_EXT
    #endif
}
