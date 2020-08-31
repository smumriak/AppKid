//
//  VkPipelineStageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkPipelineStageFlagBits {
    static let topOfPipe = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT
    static let drawIndirect = VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT
    static let vertexInput = VK_PIPELINE_STAGE_VERTEX_INPUT_BIT
    static let vertexShader = VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
    static let tessellationControlShader = VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT
    static let tessellationEvaluationShader = VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT
    static let geometryShader = VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT
    static let fragmentShader = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    static let earlyFragmentTests = VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT
    static let lateFragmentTests = VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT
    static let colorAttachmentOutput = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    static let computeShader = VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT
    static let transfer = VK_PIPELINE_STAGE_TRANSFER_BIT
    static let bottomOfPipe = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT
    static let host = VK_PIPELINE_STAGE_HOST_BIT
    static let allGraphics = VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT
    static let allCommands = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT
    static let transformFeedbackExt = VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT
    static let conditionalRenderingExt = VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT
    static let rayTracingShaderKhr = VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR
    static let accelerationStructureBuildKhr = VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR
    static let shadingRateImageNv = VK_PIPELINE_STAGE_SHADING_RATE_IMAGE_BIT_NV
    static let taskShaderNv = VK_PIPELINE_STAGE_TASK_SHADER_BIT_NV
    static let meshShaderNv = VK_PIPELINE_STAGE_MESH_SHADER_BIT_NV
    static let fragmentDensityProcessExt = VK_PIPELINE_STAGE_FRAGMENT_DENSITY_PROCESS_BIT_EXT
    static let commandPreprocessNv = VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV
    static let rayTracingShaderNv = VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_NV
    static let accelerationStructureBuildNv = VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_NV
}
