//
//  VkBufferUsageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension VkBufferUsageFlagBits {
    public static let transferSource = VK_BUFFER_USAGE_TRANSFER_SRC_BIT
    public static let transferDestination = VK_BUFFER_USAGE_TRANSFER_DST_BIT
    public static let uniformTexelBuffer = VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT
    public static let storageTexelBuffer = VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT
    public static let uniformBuffer = VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT
    public static let storageBuffer = VK_BUFFER_USAGE_STORAGE_BUFFER_BIT
    public static let indexBuffer = VK_BUFFER_USAGE_INDEX_BUFFER_BIT
    public static let vertexBuffer = VK_BUFFER_USAGE_VERTEX_BUFFER_BIT
    public static let indirectBuffer = VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT
    public static let shaderDeviceAddress = VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT
    public static let transformFeedbackBufferExt = VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT
    public static let transformFeedbackCounterBufferExt = VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT
    public static let conditionalRenderingExt = VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT
    public static let rayTracingKhr = VK_BUFFER_USAGE_RAY_TRACING_BIT_KHR
    public static let rayTracingNv = VK_BUFFER_USAGE_RAY_TRACING_BIT_NV
    public static let shaderDeviceAddressExt = VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_EXT
    public static let shaderDeviceAddressKhr = VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_KHR
}
