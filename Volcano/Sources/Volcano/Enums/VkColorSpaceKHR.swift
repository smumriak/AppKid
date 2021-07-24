//
//  VkColorSpaceKHR.swift
//  Volcano
//
//  Created by Serhii Mumriak on 27.12.2020.
//

import CVulkan

public typealias VkColorSpaceKHR = CVulkan.VkColorSpaceKHR

public extension VkColorSpaceKHR {
    static let srgbNonlinear: Self = .VK_COLOR_SPACE_SRGB_NONLINEAR_KHR
    static let displayP3Nonlinear: Self = .VK_COLOR_SPACE_DISPLAY_P3_NONLINEAR_EXT
    static let extendedSRGBLinear: Self = .VK_COLOR_SPACE_EXTENDED_SRGB_LINEAR_EXT
    static let displayP3Linear: Self = .VK_COLOR_SPACE_DISPLAY_P3_LINEAR_EXT
    static let dciP3Nonlinear: Self = .VK_COLOR_SPACE_DCI_P3_NONLINEAR_EXT
    static let bt709Linear: Self = .VK_COLOR_SPACE_BT709_LINEAR_EXT
    static let bt709Nonlinear: Self = .VK_COLOR_SPACE_BT709_NONLINEAR_EXT
    static let bt2020Linear: Self = .VK_COLOR_SPACE_BT2020_LINEAR_EXT
    static let hdr10ST2084: Self = .VK_COLOR_SPACE_HDR10_ST2084_EXT
    static let dolbyVision: Self = .VK_COLOR_SPACE_DOLBYVISION_EXT
    static let hdr10HLG: Self = .VK_COLOR_SPACE_HDR10_HLG_EXT
    static let adobeRGBLinear: Self = .VK_COLOR_SPACE_ADOBERGB_LINEAR_EXT
    static let adobeRGBNonlinear: Self = .VK_COLOR_SPACE_ADOBERGB_NONLINEAR_EXT
    static let passThrough: Self = .VK_COLOR_SPACE_PASS_THROUGH_EXT
    static let extendedSRGBNonlinear: Self = .VK_COLOR_SPACE_EXTENDED_SRGB_NONLINEAR_EXT
    static let displayNativeAMD: Self = .VK_COLOR_SPACE_DISPLAY_NATIVE_AMD
}
