//
//  VkImageCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//


extension VkImageCreateFlagBits {
    public static let sparseBinding = VK_IMAGE_CREATE_SPARSE_BINDING_BIT
    public static let sparseResidency = VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT
    public static let sparseAliased = VK_IMAGE_CREATE_SPARSE_ALIASED_BIT
    public static let mutableFormat = VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT
    public static let cubeCompatible = VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT
    public static let alias = VK_IMAGE_CREATE_ALIAS_BIT
    public static let splitInstanceBindRegions = VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT
    public static let twoDimensionalArrayCompatible = VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT
    public static let blockTexelViewCompatible = VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT
    public static let extendedUsage = VK_IMAGE_CREATE_EXTENDED_USAGE_BIT
    public static let protected = VK_IMAGE_CREATE_PROTECTED_BIT
    public static let disjoint = VK_IMAGE_CREATE_DISJOINT_BIT
    public static let cornerSampledNv = VK_IMAGE_CREATE_CORNER_SAMPLED_BIT_NV
    public static let sampleLocationsCompatibleDepthExt = VK_IMAGE_CREATE_SAMPLE_LOCATIONS_COMPATIBLE_DEPTH_BIT_EXT
    public static let subsampledExt = VK_IMAGE_CREATE_SUBSAMPLED_BIT_EXT
    public static let splitInstanceBindRegionsKhr = VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT_KHR
    public static let twoDimensionalArrayCompatibleKhr = VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT_KHR
    public static let blockTexelViewCompatibleKhr = VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT_KHR
    public static let extendedUsageKhr = VK_IMAGE_CREATE_EXTENDED_USAGE_BIT_KHR
    public static let disjointKhr = VK_IMAGE_CREATE_DISJOINT_BIT_KHR
    public static let aliasKhr = VK_IMAGE_CREATE_ALIAS_BIT_KHR
}
