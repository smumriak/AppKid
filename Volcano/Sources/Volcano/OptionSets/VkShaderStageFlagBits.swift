//
//  VkShaderStageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkShaderStageFlagBits {
    static let vertex = VK_SHADER_STAGE_VERTEX_BIT
    static let tessellationControl = VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT
    static let tessellationEvaluation = VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT
    static let geometry = VK_SHADER_STAGE_GEOMETRY_BIT
    static let fragment = VK_SHADER_STAGE_FRAGMENT_BIT
    static let compute = VK_SHADER_STAGE_COMPUTE_BIT
    static let allGraphics = VK_SHADER_STAGE_ALL_GRAPHICS
    static let all = VK_SHADER_STAGE_ALL
    static let raygenKhr = VK_SHADER_STAGE_RAYGEN_BIT_KHR
    static let anyHitKhr = VK_SHADER_STAGE_ANY_HIT_BIT_KHR
    static let closestHitKhr = VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR
    static let missKhr = VK_SHADER_STAGE_MISS_BIT_KHR
    static let intersectionKhr = VK_SHADER_STAGE_INTERSECTION_BIT_KHR
    static let callableKhr = VK_SHADER_STAGE_CALLABLE_BIT_KHR
    static let taskNv = VK_SHADER_STAGE_TASK_BIT_NV
    static let meshNv = VK_SHADER_STAGE_MESH_BIT_NV
    static let raygenNv = VK_SHADER_STAGE_RAYGEN_BIT_NV
    static let anyHitNv = VK_SHADER_STAGE_ANY_HIT_BIT_NV
    static let closestHitNv = VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV
    static let missNv = VK_SHADER_STAGE_MISS_BIT_NV
    static let intersectionNv = VK_SHADER_STAGE_INTERSECTION_BIT_NV
    static let callableNv = VK_SHADER_STAGE_CALLABLE_BIT_NV
}
