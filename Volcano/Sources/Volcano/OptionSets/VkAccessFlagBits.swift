//
//  VkAccessFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public typealias VkAccessFlagBits = CVulkan.VkAccessFlagBits

public extension VkAccessFlagBits {
    static let indirectCommandRead = VK_ACCESS_INDIRECT_COMMAND_READ_BIT
    static let indexRead = VK_ACCESS_INDEX_READ_BIT
    static let vertexAttributeRead = VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT
    static let uniformRead = VK_ACCESS_UNIFORM_READ_BIT
    static let inputAttachmentRead = VK_ACCESS_INPUT_ATTACHMENT_READ_BIT
    static let shaderRead = VK_ACCESS_SHADER_READ_BIT
    static let shaderWrite = VK_ACCESS_SHADER_WRITE_BIT
    static let colorAttachmentRead = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT
    static let colorAttachmentWrite = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
    static let depthStencilAttachmentRead = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT
    static let depthStencilAttachmentWrite = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    static let transferRead = VK_ACCESS_TRANSFER_READ_BIT
    static let transferWrite = VK_ACCESS_TRANSFER_WRITE_BIT
    static let hostRead = VK_ACCESS_HOST_READ_BIT
    static let hostWrite = VK_ACCESS_HOST_WRITE_BIT
    static let memoryRead = VK_ACCESS_MEMORY_READ_BIT
    static let memoryWrite = VK_ACCESS_MEMORY_WRITE_BIT
    static let transformFeedbackWrite = VK_ACCESS_TRANSFORM_FEEDBACK_WRITE_BIT_EXT
    static let transformFeedbackCounterRead = VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT
    static let transformFeedbackCounterWrite = VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT
    static let conditionalRenderingRead = VK_ACCESS_CONDITIONAL_RENDERING_READ_BIT_EXT
    static let colorAttachmentReadNoncoherent = VK_ACCESS_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT
    static let accelerationStructureReadKhr = VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR
    static let accelerationStructureWriteKhr = VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR
    static let shadingRateImageRead = VK_ACCESS_SHADING_RATE_IMAGE_READ_BIT_NV
    static let fragmentDensityMapRead = VK_ACCESS_FRAGMENT_DENSITY_MAP_READ_BIT_EXT
    static let commandPreprocessRead = VK_ACCESS_COMMAND_PREPROCESS_READ_BIT_NV
    static let commandPreprocessWrite = VK_ACCESS_COMMAND_PREPROCESS_WRITE_BIT_NV
    static let accelerationStructureRead = VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_NV
    static let accelerationStructureWrite = VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV
}
