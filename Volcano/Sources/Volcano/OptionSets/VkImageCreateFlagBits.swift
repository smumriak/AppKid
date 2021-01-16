//
//  VkImageCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkImageCreateFlagBits = CVulkan.VkImageCreateFlagBits

public extension VkImageCreateFlagBits {
    static let sparseBinding = VK_IMAGE_CREATE_SPARSE_BINDING_BIT
    static let sparseResidency = VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT
    static let sparseAliased = VK_IMAGE_CREATE_SPARSE_ALIASED_BIT
    static let mutableFormat = VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
    static let cubeCompatible = VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT
    static let alias = VK_IMAGE_CREATE_ALIAS_BIT
    static let splitInstanceBindRegions = VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT
    static let twoDimensionalArrayCompatible = VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT
    static let blockTexelViewCompatible = VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT
    static let extendedUsage = VK_IMAGE_CREATE_EXTENDED_USAGE_BIT
    static let protected = VK_IMAGE_CREATE_PROTECTED_BIT
    static let disjoint = VK_IMAGE_CREATE_DISJOINT_BIT
    static let cornerSampledNv = VK_IMAGE_CREATE_CORNER_SAMPLED_BIT_NV
    static let sampleLocationsCompatibleDepthExt = VK_IMAGE_CREATE_SAMPLE_LOCATIONS_COMPATIBLE_DEPTH_BIT_EXT
    static let subsampledExt = VK_IMAGE_CREATE_SUBSAMPLED_BIT_EXT
    static let splitInstanceBindRegionsKhr = VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT_KHR
    static let twoDimensionalArrayCompatibleKhr = VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT_KHR
    static let blockTexelViewCompatibleKhr = VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT_KHR
    static let extendedUsageKhr = VK_IMAGE_CREATE_EXTENDED_USAGE_BIT_KHR
    static let disjointKhr = VK_IMAGE_CREATE_DISJOINT_BIT_KHR
    static let aliasKhr = VK_IMAGE_CREATE_ALIAS_BIT_KHR
}
