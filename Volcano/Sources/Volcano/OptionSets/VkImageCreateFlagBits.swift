//
//  VkImageCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkImageCreateFlagBits = CVulkan.VkImageCreateFlagBits

public extension VkImageCreateFlagBits {
    static let sparseBinding: Self = .VK_IMAGE_CREATE_SPARSE_BINDING_BIT
    static let sparseResidency: Self = .VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT
    static let sparseAliased: Self = .VK_IMAGE_CREATE_SPARSE_ALIASED_BIT
    static let mutableFormat: Self = .VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
    static let cubeCompatible: Self = .VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT
    static let alias: Self = .VK_IMAGE_CREATE_ALIAS_BIT
    static let splitInstanceBindRegions: Self = .VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT
    static let twoDimensionalArrayCompatible: Self = .VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT
    static let blockTexelViewCompatible: Self = .VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT
    static let extendedUsage: Self = .VK_IMAGE_CREATE_EXTENDED_USAGE_BIT
    static let protected: Self = .VK_IMAGE_CREATE_PROTECTED_BIT
    static let disjoint: Self = .VK_IMAGE_CREATE_DISJOINT_BIT
    static let cornerSampledNv: Self = .VK_IMAGE_CREATE_CORNER_SAMPLED_BIT_NV
    static let sampleLocationsCompatibleDepthExt: Self = .VK_IMAGE_CREATE_SAMPLE_LOCATIONS_COMPATIBLE_DEPTH_BIT_EXT
    static let subsampledExt: Self = .VK_IMAGE_CREATE_SUBSAMPLED_BIT_EXT
    static let splitInstanceBindRegionsKhr: Self = .VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT_KHR
    static let twoDimensionalArrayCompatibleKhr: Self = .VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT_KHR
    static let blockTexelViewCompatibleKhr: Self = .VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT_KHR
    static let extendedUsageKhr: Self = .VK_IMAGE_CREATE_EXTENDED_USAGE_BIT_KHR
    static let disjointKhr: Self = .VK_IMAGE_CREATE_DISJOINT_BIT_KHR
    static let aliasKhr: Self = .VK_IMAGE_CREATE_ALIAS_BIT_KHR
}
