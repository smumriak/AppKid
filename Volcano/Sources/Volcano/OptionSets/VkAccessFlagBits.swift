//
//  VkAccessFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public typealias VkAccessFlagBits = CVulkan.VkAccessFlagBits

public extension VkAccessFlagBits {
    static let indirectCommandRead: Self = .VK_ACCESS_INDIRECT_COMMAND_READ_BIT
    static let indexRead: Self = .VK_ACCESS_INDEX_READ_BIT
    static let vertexAttributeRead: Self = .VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT
    static let uniformRead: Self = .VK_ACCESS_UNIFORM_READ_BIT
    static let inputAttachmentRead: Self = .VK_ACCESS_INPUT_ATTACHMENT_READ_BIT
    static let shaderRead: Self = .VK_ACCESS_SHADER_READ_BIT
    static let shaderWrite: Self = .VK_ACCESS_SHADER_WRITE_BIT
    static let colorAttachmentRead: Self = .VK_ACCESS_COLOR_ATTACHMENT_READ_BIT
    static let colorAttachmentWrite: Self = .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
    static let depthStencilAttachmentRead: Self = .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT
    static let depthStencilAttachmentWrite: Self = .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    static let transferRead: Self = .VK_ACCESS_TRANSFER_READ_BIT
    static let transferWrite: Self = .VK_ACCESS_TRANSFER_WRITE_BIT
    static let hostRead: Self = .VK_ACCESS_HOST_READ_BIT
    static let hostWrite: Self = .VK_ACCESS_HOST_WRITE_BIT
    static let memoryRead: Self = .VK_ACCESS_MEMORY_READ_BIT
    static let memoryWrite: Self = .VK_ACCESS_MEMORY_WRITE_BIT
    static let transformFeedbackWrite: Self = .VK_ACCESS_TRANSFORM_FEEDBACK_WRITE_BIT_EXT
    static let transformFeedbackCounterRead: Self = .VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT
    static let transformFeedbackCounterWrite: Self = .VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT
    static let conditionalRenderingRead: Self = .VK_ACCESS_CONDITIONAL_RENDERING_READ_BIT_EXT
    static let colorAttachmentReadNoncoherent: Self = .VK_ACCESS_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT
    static let accelerationStructureReadKhr: Self = .VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR
    static let accelerationStructureWriteKhr: Self = .VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR
    static let shadingRateImageRead: Self = .VK_ACCESS_SHADING_RATE_IMAGE_READ_BIT_NV
    static let fragmentDensityMapRead: Self = .VK_ACCESS_FRAGMENT_DENSITY_MAP_READ_BIT_EXT
    static let commandPreprocessRead: Self = .VK_ACCESS_COMMAND_PREPROCESS_READ_BIT_NV
    static let commandPreprocessWrite: Self = .VK_ACCESS_COMMAND_PREPROCESS_WRITE_BIT_NV
    static let accelerationStructureRead: Self = .VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_NV
    static let accelerationStructureWrite: Self = .VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV
}
