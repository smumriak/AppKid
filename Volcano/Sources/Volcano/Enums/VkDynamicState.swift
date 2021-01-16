//
//  VkDynamicState.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkDynamicState = CVulkan.VkDynamicState

public extension VkDynamicState {
    static let viewport: VkDynamicState = .VK_DYNAMIC_STATE_VIEWPORT
    static let scissor: VkDynamicState = .VK_DYNAMIC_STATE_SCISSOR
    static let lineWidth: VkDynamicState = .VK_DYNAMIC_STATE_LINE_WIDTH
    static let depthBias: VkDynamicState = .VK_DYNAMIC_STATE_DEPTH_BIAS
    static let blendConstants: VkDynamicState = .VK_DYNAMIC_STATE_BLEND_CONSTANTS
    static let depthBounds: VkDynamicState = .VK_DYNAMIC_STATE_DEPTH_BOUNDS
    static let stencilCompareMask: VkDynamicState = .VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK
    static let stencilWriteMask: VkDynamicState = .VK_DYNAMIC_STATE_STENCIL_WRITE_MASK
    static let stencilWeference: VkDynamicState = .VK_DYNAMIC_STATE_STENCIL_REFERENCE
    static let viewportWScalingNV: VkDynamicState = .VK_DYNAMIC_STATE_VIEWPORT_W_SCALING_NV
    static let discardRectangleExt: VkDynamicState = .VK_DYNAMIC_STATE_DISCARD_RECTANGLE_EXT
    static let sampleLocationsExt: VkDynamicState = .VK_DYNAMIC_STATE_SAMPLE_LOCATIONS_EXT
    static let viewportShadingRatePaletteNV: VkDynamicState = .VK_DYNAMIC_STATE_VIEWPORT_SHADING_RATE_PALETTE_NV
    static let viewportCoarseSampleOrderNV: VkDynamicState = .VK_DYNAMIC_STATE_VIEWPORT_COARSE_SAMPLE_ORDER_NV
    static let exclusiveScissor_nv: VkDynamicState = .VK_DYNAMIC_STATE_EXCLUSIVE_SCISSOR_NV
    static let lineStippleExt: VkDynamicState = .VK_DYNAMIC_STATE_LINE_STIPPLE_EXT
    #if !os(macOS)
    // static let cullModeExt: VkDynamicState = .VK_DYNAMIC_STATE_CULL_MODE_EXT
    // static let frontFaceExt: VkDynamicState = .VK_DYNAMIC_STATE_FRONT_FACE_EXT
    // static let primitiveTopologyExt: VkDynamicState = .VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY_EXT
    // static let viewportWithCountExt: VkDynamicState = .VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT_EXT
    // static let scissorWithCountExt: VkDynamicState = .VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT_EXT
    // static let vertexInputBindingStrideExt: VkDynamicState = .VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE_EXT
    // static let depthTestEnableExt: VkDynamicState = .VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE_EXT
    // static let depthWriteEnableExt: VkDynamicState = .VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE_EXT
    // static let depthCompareOperationExt: VkDynamicState = .VK_DYNAMIC_STATE_DEPTH_COMPARE_OP_EXT
    // static let depthBoundsTestEnableExt: VkDynamicState = .VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE_EXT
    // static let stencilTestEnableExt: VkDynamicState = .VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE_EXT
    // static let stencilOperationExt: VkDynamicState = .VK_DYNAMIC_STATE_STENCIL_OP_EXT
    #endif
}
