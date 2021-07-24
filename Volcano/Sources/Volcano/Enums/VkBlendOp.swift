//
//  VkBlendOp.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkBlendOp = CVulkan.VkBlendOp

public extension VkBlendOp {
    static let add: Self = .VK_BLEND_OP_ADD
    static let subtract: Self = .VK_BLEND_OP_SUBTRACT
    static let reverseSubtract: Self = .VK_BLEND_OP_REVERSE_SUBTRACT
    static let min: Self = .VK_BLEND_OP_MIN
    static let max: Self = .VK_BLEND_OP_MAX
    static let zeroExt: Self = .VK_BLEND_OP_ZERO_EXT
    static let srcExt: Self = .VK_BLEND_OP_SRC_EXT
    static let dstExt: Self = .VK_BLEND_OP_DST_EXT
    static let srcOverExt: Self = .VK_BLEND_OP_SRC_OVER_EXT
    static let dstOverExt: Self = .VK_BLEND_OP_DST_OVER_EXT
    static let srcInExt: Self = .VK_BLEND_OP_SRC_IN_EXT
    static let dstInExt: Self = .VK_BLEND_OP_DST_IN_EXT
    static let srcOutExt: Self = .VK_BLEND_OP_SRC_OUT_EXT
    static let dstOutExt: Self = .VK_BLEND_OP_DST_OUT_EXT
    static let srcATopExt: Self = .VK_BLEND_OP_SRC_ATOP_EXT
    static let dstATopExt: Self = .VK_BLEND_OP_DST_ATOP_EXT
    static let xorExt: Self = .VK_BLEND_OP_XOR_EXT
    static let multiplyExt: Self = .VK_BLEND_OP_MULTIPLY_EXT
    static let screenExt: Self = .VK_BLEND_OP_SCREEN_EXT
    static let overlayExt: Self = .VK_BLEND_OP_OVERLAY_EXT
    static let darkenExt: Self = .VK_BLEND_OP_DARKEN_EXT
    static let lightenExt: Self = .VK_BLEND_OP_LIGHTEN_EXT
    static let colordodgeExt: Self = .VK_BLEND_OP_COLORDODGE_EXT
    static let colorburnExt: Self = .VK_BLEND_OP_COLORBURN_EXT
    static let hardlightExt: Self = .VK_BLEND_OP_HARDLIGHT_EXT
    static let softlightExt: Self = .VK_BLEND_OP_SOFTLIGHT_EXT
    static let differenceExt: Self = .VK_BLEND_OP_DIFFERENCE_EXT
    static let exclusionExt: Self = .VK_BLEND_OP_EXCLUSION_EXT
    static let invertExt: Self = .VK_BLEND_OP_INVERT_EXT
    static let invertRGBExt: Self = .VK_BLEND_OP_INVERT_RGB_EXT
    static let lineardodgeExt: Self = .VK_BLEND_OP_LINEARDODGE_EXT
    static let linearburnExt: Self = .VK_BLEND_OP_LINEARBURN_EXT
    static let vividlightExt: Self = .VK_BLEND_OP_VIVIDLIGHT_EXT
    static let linearlightExt: Self = .VK_BLEND_OP_LINEARLIGHT_EXT
    static let pinlightExt: Self = .VK_BLEND_OP_PINLIGHT_EXT
    static let hardmixExt: Self = .VK_BLEND_OP_HARDMIX_EXT
    static let hslHueExt: Self = .VK_BLEND_OP_HSL_HUE_EXT
    static let hslSaturationExt: Self = .VK_BLEND_OP_HSL_SATURATION_EXT
    static let hslColorExt: Self = .VK_BLEND_OP_HSL_COLOR_EXT
    static let hslLuminosityExt: Self = .VK_BLEND_OP_HSL_LUMINOSITY_EXT
    static let plusExt: Self = .VK_BLEND_OP_PLUS_EXT
    static let plusClampedExt: Self = .VK_BLEND_OP_PLUS_CLAMPED_EXT
    static let plusClamped_alphaExt: Self = .VK_BLEND_OP_PLUS_CLAMPED_ALPHA_EXT
    static let plusDarkerExt: Self = .VK_BLEND_OP_PLUS_DARKER_EXT
    static let minusExt: Self = .VK_BLEND_OP_MINUS_EXT
    static let minusClampedExt: Self = .VK_BLEND_OP_MINUS_CLAMPED_EXT
    static let contrastExt: Self = .VK_BLEND_OP_CONTRAST_EXT
    static let invertOvgExt: Self = .VK_BLEND_OP_INVERT_OVG_EXT
    static let redExt: Self = .VK_BLEND_OP_RED_EXT
    static let greenExt: Self = .VK_BLEND_OP_GREEN_EXT
    static let blueExt: VkBlendOp = .VK_BLEND_OP_BLUE_EXT
}
