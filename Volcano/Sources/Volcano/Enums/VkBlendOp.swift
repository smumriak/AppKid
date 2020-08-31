//
//  VkBlendOp.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

extension VkBlendOp {
    public static let add: VkBlendOp = .VK_BLEND_OP_ADD
    public static let subtract: VkBlendOp = .VK_BLEND_OP_SUBTRACT
    public static let reverseSubtract: VkBlendOp = .VK_BLEND_OP_REVERSE_SUBTRACT
    public static let min: VkBlendOp = .VK_BLEND_OP_MIN
    public static let max: VkBlendOp = .VK_BLEND_OP_MAX
    public static let zeroExt: VkBlendOp = .VK_BLEND_OP_ZERO_EXT
    public static let srcExt: VkBlendOp = .VK_BLEND_OP_SRC_EXT
    public static let dstExt: VkBlendOp = .VK_BLEND_OP_DST_EXT
    public static let srcOverExt: VkBlendOp = .VK_BLEND_OP_SRC_OVER_EXT
    public static let dstOverExt: VkBlendOp = .VK_BLEND_OP_DST_OVER_EXT
    public static let srcInExt: VkBlendOp = .VK_BLEND_OP_SRC_IN_EXT
    public static let dstInExt: VkBlendOp = .VK_BLEND_OP_DST_IN_EXT
    public static let srcOutExt: VkBlendOp = .VK_BLEND_OP_SRC_OUT_EXT
    public static let dstOutExt: VkBlendOp = .VK_BLEND_OP_DST_OUT_EXT
    public static let srcATopExt: VkBlendOp = .VK_BLEND_OP_SRC_ATOP_EXT
    public static let dstATopExt: VkBlendOp = .VK_BLEND_OP_DST_ATOP_EXT
    public static let xorExt: VkBlendOp = .VK_BLEND_OP_XOR_EXT
    public static let multiplyExt: VkBlendOp = .VK_BLEND_OP_MULTIPLY_EXT
    public static let screenExt: VkBlendOp = .VK_BLEND_OP_SCREEN_EXT
    public static let overlayExt: VkBlendOp = .VK_BLEND_OP_OVERLAY_EXT
    public static let darkenExt: VkBlendOp = .VK_BLEND_OP_DARKEN_EXT
    public static let lightenExt: VkBlendOp = .VK_BLEND_OP_LIGHTEN_EXT
    public static let colordodgeExt: VkBlendOp = .VK_BLEND_OP_COLORDODGE_EXT
    public static let colorburnExt: VkBlendOp = .VK_BLEND_OP_COLORBURN_EXT
    public static let hardlightExt: VkBlendOp = .VK_BLEND_OP_HARDLIGHT_EXT
    public static let softlightExt: VkBlendOp = .VK_BLEND_OP_SOFTLIGHT_EXT
    public static let differenceExt: VkBlendOp = .VK_BLEND_OP_DIFFERENCE_EXT
    public static let exclusionExt: VkBlendOp = .VK_BLEND_OP_EXCLUSION_EXT
    public static let invertExt: VkBlendOp = .VK_BLEND_OP_INVERT_EXT
    public static let invertRGBExt: VkBlendOp = .VK_BLEND_OP_INVERT_RGB_EXT
    public static let lineardodgeExt: VkBlendOp = .VK_BLEND_OP_LINEARDODGE_EXT
    public static let linearburnExt: VkBlendOp = .VK_BLEND_OP_LINEARBURN_EXT
    public static let vividlightExt: VkBlendOp = .VK_BLEND_OP_VIVIDLIGHT_EXT
    public static let linearlightExt: VkBlendOp = .VK_BLEND_OP_LINEARLIGHT_EXT
    public static let pinlightExt: VkBlendOp = .VK_BLEND_OP_PINLIGHT_EXT
    public static let hardmixExt: VkBlendOp = .VK_BLEND_OP_HARDMIX_EXT
    public static let hslHueExt: VkBlendOp = .VK_BLEND_OP_HSL_HUE_EXT
    public static let hslSaturationExt: VkBlendOp = .VK_BLEND_OP_HSL_SATURATION_EXT
    public static let hslColorExt: VkBlendOp = .VK_BLEND_OP_HSL_COLOR_EXT
    public static let hslLuminosityExt: VkBlendOp = .VK_BLEND_OP_HSL_LUMINOSITY_EXT
    public static let plusExt: VkBlendOp = .VK_BLEND_OP_PLUS_EXT
    public static let plusClampedExt: VkBlendOp = .VK_BLEND_OP_PLUS_CLAMPED_EXT
    public static let plusClamped_alphaExt: VkBlendOp = .VK_BLEND_OP_PLUS_CLAMPED_ALPHA_EXT
    public static let plusDarkerExt: VkBlendOp = .VK_BLEND_OP_PLUS_DARKER_EXT
    public static let minusExt: VkBlendOp = .VK_BLEND_OP_MINUS_EXT
    public static let minusClampedExt: VkBlendOp = .VK_BLEND_OP_MINUS_CLAMPED_EXT
    public static let contrastExt: VkBlendOp = .VK_BLEND_OP_CONTRAST_EXT
    public static let invertOvgExt: VkBlendOp = .VK_BLEND_OP_INVERT_OVG_EXT
    public static let redExt: VkBlendOp = .VK_BLEND_OP_RED_EXT
    public static let greenExt: VkBlendOp = .VK_BLEND_OP_GREEN_EXT
    public static let blueExt: VkBlendOp = .VK_BLEND_OP_BLUE_EXT
}
