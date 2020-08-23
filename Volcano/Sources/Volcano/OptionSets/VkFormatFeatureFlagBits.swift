//
//  VkFormatFeatureFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//


extension VkFormatFeatureFlagBits {
    public static let sampledImage = VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT
    public static let storageImage = VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT
    public static let storageImageAtomic = VK_FORMAT_FEATURE_STORAGE_IMAGE_ATOMIC_BIT
    public static let uniformTexelBuffer = VK_FORMAT_FEATURE_UNIFORM_TEXEL_BUFFER_BIT
    public static let storageTexelBuffer = VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_BIT
    public static let storageTexelBufferAtomic = VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_ATOMIC_BIT
    public static let vertexBuffer = VK_FORMAT_FEATURE_VERTEX_BUFFER_BIT
    public static let colorAttachment = VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT
    public static let colorAttachmentBlend = VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT
    public static let depthStencilAttachment = VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT
    public static let blitSrc = VK_FORMAT_FEATURE_BLIT_SRC_BIT
    public static let blitDst = VK_FORMAT_FEATURE_BLIT_DST_BIT
    public static let sampledImageFilterLinear = VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT
    public static let transferSrc = VK_FORMAT_FEATURE_TRANSFER_SRC_BIT
    public static let transferDst = VK_FORMAT_FEATURE_TRANSFER_DST_BIT
    public static let midpointChromaSamples = VK_FORMAT_FEATURE_MIDPOINT_CHROMA_SAMPLES_BIT
    public static let sampledImageYcbcrConversionLinearFilter = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_LINEAR_FILTER_BIT
    public static let sampledImageYcbcrConversionSeparateReconstructionFilter = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_SEPARATE_RECONSTRUCTION_FILTER_BIT
    public static let sampledImageYcbcrConversionChromaReconstructionExplicit = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_BIT
    public static let sampledImageYcbcrConversionChromaReconstructionExplicitForceable = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_FORCEABLE_BIT
    public static let disjoint = VK_FORMAT_FEATURE_DISJOINT_BIT
    public static let cositedChromaSamples = VK_FORMAT_FEATURE_COSITED_CHROMA_SAMPLES_BIT
    public static let sampledImageFilterMinmax = VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_MINMAX_BIT
    public static let sampledImageFilterCubicImg = VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_IMG
    public static let accelerationStructureVertexBufferKhr = VK_FORMAT_FEATURE_ACCELERATION_STRUCTURE_VERTEX_BUFFER_BIT_KHR
    public static let fragmentDensityMapExt = VK_FORMAT_FEATURE_FRAGMENT_DENSITY_MAP_BIT_EXT
    public static let transferSrcKhr = VK_FORMAT_FEATURE_TRANSFER_SRC_BIT_KHR
    public static let transferDstKhr = VK_FORMAT_FEATURE_TRANSFER_DST_BIT_KHR
    public static let sampledImageFilterMinmaxExt = VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_MINMAX_BIT_EXT
    public static let midpointChromaSamplesKhr = VK_FORMAT_FEATURE_MIDPOINT_CHROMA_SAMPLES_BIT_KHR
    public static let sampledImageYcbcrConversionLinearFilterKhr = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_LINEAR_FILTER_BIT_KHR
    public static let sampledImageYcbcrConversionSeparateReconstructionFilterKhr = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_SEPARATE_RECONSTRUCTION_FILTER_BIT_KHR
    public static let sampledImageYcbcrConversionChromaReconstructionExplicitKhr = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_BIT_KHR
    public static let sampledImageYcbcrConversionChromaReconstructionExplicitForceableKhr = VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_FORCEABLE_BIT_KHR
    public static let disjointKhr = VK_FORMAT_FEATURE_DISJOINT_BIT_KHR
    public static let cositedChromaSamplesKhr = VK_FORMAT_FEATURE_COSITED_CHROMA_SAMPLES_BIT_KHR
    public static let sampledImageFilterCubicExt = VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_EXT
}
