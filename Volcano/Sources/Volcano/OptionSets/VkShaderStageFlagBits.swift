//
//  VkShaderStageFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//


extension VkShaderStageFlagBits {
    public static let vertex = VK_SHADER_STAGE_VERTEX_BIT
    public static let tessellationControl = VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT
    public static let tessellationEvaluation = VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT
    public static let geometry = VK_SHADER_STAGE_GEOMETRY_BIT
    public static let fragment = VK_SHADER_STAGE_FRAGMENT_BIT
    public static let compute = VK_SHADER_STAGE_COMPUTE_BIT
    public static let allGraphics = VK_SHADER_STAGE_ALL_GRAPHICS
    public static let all = VK_SHADER_STAGE_ALL
    public static let raygenKhr = VK_SHADER_STAGE_RAYGEN_BIT_KHR
    public static let anyHitKhr = VK_SHADER_STAGE_ANY_HIT_BIT_KHR
    public static let closestHitKhr = VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR
    public static let missKhr = VK_SHADER_STAGE_MISS_BIT_KHR
    public static let intersectionKhr = VK_SHADER_STAGE_INTERSECTION_BIT_KHR
    public static let callableKhr = VK_SHADER_STAGE_CALLABLE_BIT_KHR
    public static let taskNv = VK_SHADER_STAGE_TASK_BIT_NV
    public static let meshNv = VK_SHADER_STAGE_MESH_BIT_NV
    public static let raygenNv = VK_SHADER_STAGE_RAYGEN_BIT_NV
    public static let anyHitNv = VK_SHADER_STAGE_ANY_HIT_BIT_NV
    public static let closestHitNv = VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV
    public static let missNv = VK_SHADER_STAGE_MISS_BIT_NV
    public static let intersectionNv = VK_SHADER_STAGE_INTERSECTION_BIT_NV
    public static let callableNv = VK_SHADER_STAGE_CALLABLE_BIT_NV
}
