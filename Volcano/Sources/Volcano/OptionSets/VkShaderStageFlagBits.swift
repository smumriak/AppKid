//
//  VkShaderStageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkShaderStageFlagBits = CVulkan.VkShaderStageFlagBits

public extension VkShaderStageFlagBits {
    static let vertex: Self = .VK_SHADER_STAGE_VERTEX_BIT
    static let tessellationControl: Self = .VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT
    static let tessellationEvaluation: Self = .VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT
    static let geometry: Self = .VK_SHADER_STAGE_GEOMETRY_BIT
    static let fragment: Self = .VK_SHADER_STAGE_FRAGMENT_BIT
    static let compute: Self = .VK_SHADER_STAGE_COMPUTE_BIT
    static let allGraphics: Self = .VK_SHADER_STAGE_ALL_GRAPHICS
    static let all: Self = .VK_SHADER_STAGE_ALL
    static let raygenKhr: Self = .VK_SHADER_STAGE_RAYGEN_BIT_KHR
    static let anyHitKhr: Self = .VK_SHADER_STAGE_ANY_HIT_BIT_KHR
    static let closestHitKhr: Self = .VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR
    static let missKhr: Self = .VK_SHADER_STAGE_MISS_BIT_KHR
    static let intersectionKhr: Self = .VK_SHADER_STAGE_INTERSECTION_BIT_KHR
    static let callableKhr: Self = .VK_SHADER_STAGE_CALLABLE_BIT_KHR
    static let taskNv: Self = .VK_SHADER_STAGE_TASK_BIT_NV
    static let meshNv: Self = .VK_SHADER_STAGE_MESH_BIT_NV
    static let raygenNv: Self = .VK_SHADER_STAGE_RAYGEN_BIT_NV
    static let anyHitNv: Self = .VK_SHADER_STAGE_ANY_HIT_BIT_NV
    static let closestHitNv: Self = .VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV
    static let missNv: Self = .VK_SHADER_STAGE_MISS_BIT_NV
    static let intersectionNv: Self = .VK_SHADER_STAGE_INTERSECTION_BIT_NV
    static let callableNv: Self = .VK_SHADER_STAGE_CALLABLE_BIT_NV
}
