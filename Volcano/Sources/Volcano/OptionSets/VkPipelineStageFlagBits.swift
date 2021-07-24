//
//  VkPipelineStageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkPipelineStageFlagBits = CVulkan.VkPipelineStageFlagBits

public extension VkPipelineStageFlagBits {
    static let topOfPipe: Self = .VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT
    static let drawIndirect: Self = .VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT
    static let vertexInput: Self = .VK_PIPELINE_STAGE_VERTEX_INPUT_BIT
    static let vertexShader: Self = .VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
    static let tessellationControlShader: Self = .VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT
    static let tessellationEvaluationShader: Self = .VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT
    static let geometryShader: Self = .VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT
    static let fragmentShader: Self = .VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    static let earlyFragmentTests: Self = .VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT
    static let lateFragmentTests: Self = .VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT
    static let colorAttachmentOutput: Self = .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    static let computeShader: Self = .VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT
    static let transfer: Self = .VK_PIPELINE_STAGE_TRANSFER_BIT
    static let bottomOfPipe: Self = .VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT
    static let host: Self = .VK_PIPELINE_STAGE_HOST_BIT
    static let allGraphics: Self = .VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT
    static let allCommands: Self = .VK_PIPELINE_STAGE_ALL_COMMANDS_BIT
    static let transformFeedbackExt: Self = .VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT
    static let conditionalRenderingExt: Self = .VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT
    static let rayTracingShaderKhr: Self = .VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
    static let accelerationStructureBuildKhr: Self = .VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR
    static let shadingRateImageNv: Self = .VK_PIPELINE_STAGE_SHADING_RATE_IMAGE_BIT_NV
    static let taskShaderNv: Self = .VK_PIPELINE_STAGE_TASK_SHADER_BIT_NV
    static let meshShaderNv: Self = .VK_PIPELINE_STAGE_MESH_SHADER_BIT_NV
    static let fragmentDensityProcessExt: Self = .VK_PIPELINE_STAGE_FRAGMENT_DENSITY_PROCESS_BIT_EXT
    static let commandPreprocessNv: Self = .VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV
    static let rayTracingShaderNv: Self = .VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_NV
    static let accelerationStructureBuildNv: Self = .VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_NV
}
