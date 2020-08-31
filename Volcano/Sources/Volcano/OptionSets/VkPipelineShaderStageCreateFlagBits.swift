//
//  VkPipelineShaderStageCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkPipelineShaderStageCreateFlagBits {
    static let allowVaryingSubgroupSizeExt = VK_PIPELINE_SHADER_STAGE_CREATE_ALLOW_VARYING_SUBGROUP_SIZE_BIT_EXT
    static let requireFullSubgroupsExt = VK_PIPELINE_SHADER_STAGE_CREATE_REQUIRE_FULL_SUBGROUPS_BIT_EXT
}
