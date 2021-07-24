//
//  VkBufferUsageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkBufferUsageFlagBits = CVulkan.VkBufferUsageFlagBits

public extension VkBufferUsageFlagBits {
    static let transferSource: Self = .VK_BUFFER_USAGE_TRANSFER_SRC_BIT
    static let transferDestination: Self = .VK_BUFFER_USAGE_TRANSFER_DST_BIT
    static let uniformTexelBuffer: Self = .VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT
    static let storageTexelBuffer: Self = .VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT
    static let uniformBuffer: Self = .VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT
    static let storageBuffer: Self = .VK_BUFFER_USAGE_STORAGE_BUFFER_BIT
    static let indexBuffer: Self = .VK_BUFFER_USAGE_INDEX_BUFFER_BIT
    static let vertexBuffer: Self = .VK_BUFFER_USAGE_VERTEX_BUFFER_BIT
    static let indirectBuffer: Self = .VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT
    static let shaderDeviceAddress: Self = .VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT
    static let transformFeedbackBufferExt: Self = .VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT
    static let transformFeedbackCounterBufferExt: Self = .VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT
    static let conditionalRenderingExt: Self = .VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT
    static let rayTracingNv: Self = .VK_BUFFER_USAGE_RAY_TRACING_BIT_NV
    static let shaderDeviceAddressExt: Self = .VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_EXT
    static let shaderDeviceAddressKhr: Self = .VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_KHR
}
