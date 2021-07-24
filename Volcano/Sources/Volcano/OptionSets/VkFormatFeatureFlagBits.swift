//
//  VkFormatFeatureFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkFormatFeatureFlagBits = CVulkan.VkFormatFeatureFlagBits

public extension VkFormatFeatureFlagBits {
    static let sampledImage: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT
    static let storageImage: Self = .VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT
    static let storageImageAtomic: Self = .VK_FORMAT_FEATURE_STORAGE_IMAGE_ATOMIC_BIT
    static let uniformTexelBuffer: Self = .VK_FORMAT_FEATURE_UNIFORM_TEXEL_BUFFER_BIT
    static let storageTexelBuffer: Self = .VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_BIT
    static let storageTexelBufferAtomic: Self = .VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_ATOMIC_BIT
    static let vertexBuffer: Self = .VK_FORMAT_FEATURE_VERTEX_BUFFER_BIT
    static let colorAttachment: Self = .VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT
    static let colorAttachmentBlend: Self = .VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT
    static let depthStencilAttachment: Self = .VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT
    static let blitSrc: Self = .VK_FORMAT_FEATURE_BLIT_SRC_BIT
    static let blitDst: Self = .VK_FORMAT_FEATURE_BLIT_DST_BIT
    static let sampledImageFilterLinear: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT
    static let transferSource: Self = .VK_FORMAT_FEATURE_TRANSFER_SRC_BIT
    static let transferDestination: Self = .VK_FORMAT_FEATURE_TRANSFER_DST_BIT
    static let midpointChromaSamples: Self = .VK_FORMAT_FEATURE_MIDPOINT_CHROMA_SAMPLES_BIT
    static let sampledImageYcbcrConversionLinearFilter: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_LINEAR_FILTER_BIT
    static let sampledImageYcbcrConversionSeparateReconstructionFilter: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_SEPARATE_RECONSTRUCTION_FILTER_BIT
    static let sampledImageYcbcrConversionChromaReconstructionExplicit: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_BIT
    static let sampledImageYcbcrConversionChromaReconstructionExplicitForceable: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_FORCEABLE_BIT
    static let disjoint: Self = .VK_FORMAT_FEATURE_DISJOINT_BIT
    static let cositedChromaSamples: Self = .VK_FORMAT_FEATURE_COSITED_CHROMA_SAMPLES_BIT
    static let sampledImageFilterMinmax: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_MINMAX_BIT
    static let sampledImageFilterCubicImg: Self = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_IMG
    static let accelerationStructureVertexBufferKhr: Self = .VK_FORMAT_FEATURE_ACCELERATION_STRUCTURE_VERTEX_BUFFER_BIT_KHR
    static let fragmentDensityMapExt: Self = .VK_FORMAT_FEATURE_FRAGMENT_DENSITY_MAP_BIT_EXT
}
