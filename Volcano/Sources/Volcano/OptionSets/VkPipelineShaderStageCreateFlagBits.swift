//
//  VkPipelineShaderStageCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkPipelineShaderStageCreateFlagBits = CVulkan.VkPipelineShaderStageCreateFlagBits

public extension VkPipelineShaderStageCreateFlagBits {
    static let allowVaryingSubgroupSizeExt: Self = .VK_PIPELINE_SHADER_STAGE_CREATE_ALLOW_VARYING_SUBGROUP_SIZE_BIT_EXT
    static let requireFullSubgroupsExt: Self = .VK_PIPELINE_SHADER_STAGE_CREATE_REQUIRE_FULL_SUBGROUPS_BIT_EXT
}
