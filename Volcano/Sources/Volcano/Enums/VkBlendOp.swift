//
//  VkBlendOp.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public extension VkBlendOp {
    static let add: VkBlendOp = .VK_BLEND_OP_ADD
    static let subtract: VkBlendOp = .VK_BLEND_OP_SUBTRACT
    static let reverseSubtract: VkBlendOp = .VK_BLEND_OP_REVERSE_SUBTRACT
    static let min: VkBlendOp = .VK_BLEND_OP_MIN
    static let max: VkBlendOp = .VK_BLEND_OP_MAX
    static let zeroExt: VkBlendOp = .VK_BLEND_OP_ZERO_EXT
    static let srcExt: VkBlendOp = .VK_BLEND_OP_SRC_EXT
    static let dstExt: VkBlendOp = .VK_BLEND_OP_DST_EXT
    static let srcOverExt: VkBlendOp = .VK_BLEND_OP_SRC_OVER_EXT
    static let dstOverExt: VkBlendOp = .VK_BLEND_OP_DST_OVER_EXT
    static let srcInExt: VkBlendOp = .VK_BLEND_OP_SRC_IN_EXT
    static let dstInExt: VkBlendOp = .VK_BLEND_OP_DST_IN_EXT
    static let srcOutExt: VkBlendOp = .VK_BLEND_OP_SRC_OUT_EXT
    static let dstOutExt: VkBlendOp = .VK_BLEND_OP_DST_OUT_EXT
    static let srcATopExt: VkBlendOp = .VK_BLEND_OP_SRC_ATOP_EXT
    static let dstATopExt: VkBlendOp = .VK_BLEND_OP_DST_ATOP_EXT
    static let xorExt: VkBlendOp = .VK_BLEND_OP_XOR_EXT
    static let multiplyExt: VkBlendOp = .VK_BLEND_OP_MULTIPLY_EXT
    static let screenExt: VkBlendOp = .VK_BLEND_OP_SCREEN_EXT
    static let overlayExt: VkBlendOp = .VK_BLEND_OP_OVERLAY_EXT
    static let darkenExt: VkBlendOp = .VK_BLEND_OP_DARKEN_EXT
    static let lightenExt: VkBlendOp = .VK_BLEND_OP_LIGHTEN_EXT
    static let colordodgeExt: VkBlendOp = .VK_BLEND_OP_COLORDODGE_EXT
    static let colorburnExt: VkBlendOp = .VK_BLEND_OP_COLORBURN_EXT
    static let hardlightExt: VkBlendOp = .VK_BLEND_OP_HARDLIGHT_EXT
    static let softlightExt: VkBlendOp = .VK_BLEND_OP_SOFTLIGHT_EXT
    static let differenceExt: VkBlendOp = .VK_BLEND_OP_DIFFERENCE_EXT
    static let exclusionExt: VkBlendOp = .VK_BLEND_OP_EXCLUSION_EXT
    static let invertExt: VkBlendOp = .VK_BLEND_OP_INVERT_EXT
    static let invertRGBExt: VkBlendOp = .VK_BLEND_OP_INVERT_RGB_EXT
    static let lineardodgeExt: VkBlendOp = .VK_BLEND_OP_LINEARDODGE_EXT
    static let linearburnExt: VkBlendOp = .VK_BLEND_OP_LINEARBURN_EXT
    static let vividlightExt: VkBlendOp = .VK_BLEND_OP_VIVIDLIGHT_EXT
    static let linearlightExt: VkBlendOp = .VK_BLEND_OP_LINEARLIGHT_EXT
    static let pinlightExt: VkBlendOp = .VK_BLEND_OP_PINLIGHT_EXT
    static let hardmixExt: VkBlendOp = .VK_BLEND_OP_HARDMIX_EXT
    static let hslHueExt: VkBlendOp = .VK_BLEND_OP_HSL_HUE_EXT
    static let hslSaturationExt: VkBlendOp = .VK_BLEND_OP_HSL_SATURATION_EXT
    static let hslColorExt: VkBlendOp = .VK_BLEND_OP_HSL_COLOR_EXT
    static let hslLuminosityExt: VkBlendOp = .VK_BLEND_OP_HSL_LUMINOSITY_EXT
    static let plusExt: VkBlendOp = .VK_BLEND_OP_PLUS_EXT
    static let plusClampedExt: VkBlendOp = .VK_BLEND_OP_PLUS_CLAMPED_EXT
    static let plusClamped_alphaExt: VkBlendOp = .VK_BLEND_OP_PLUS_CLAMPED_ALPHA_EXT
    static let plusDarkerExt: VkBlendOp = .VK_BLEND_OP_PLUS_DARKER_EXT
    static let minusExt: VkBlendOp = .VK_BLEND_OP_MINUS_EXT
    static let minusClampedExt: VkBlendOp = .VK_BLEND_OP_MINUS_CLAMPED_EXT
    static let contrastExt: VkBlendOp = .VK_BLEND_OP_CONTRAST_EXT
    static let invertOvgExt: VkBlendOp = .VK_BLEND_OP_INVERT_OVG_EXT
    static let redExt: VkBlendOp = .VK_BLEND_OP_RED_EXT
    static let greenExt: VkBlendOp = .VK_BLEND_OP_GREEN_EXT
    static let blueExt: VkBlendOp = .VK_BLEND_OP_BLUE_EXT
}
