//
//  VkBorderColor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021
//

import CVulkan

public typealias VkBorderColor = CVulkan.VkBorderColor

public extension VkBorderColor {
    static let transparentBlackFloat: Self = .VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK
    static let transparentBlackInt: Self = .VK_BORDER_COLOR_INT_TRANSPARENT_BLACK
    static let opaqueBlackFloat: Self = .VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK
    static let opaqueBlackInt: Self = .VK_BORDER_COLOR_INT_OPAQUE_BLACK
    static let opaqueWhiteFloat: Self = .VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE
    static let opaqueWhiteInt: Self = .VK_BORDER_COLOR_INT_OPAQUE_WHITE
    static let customExtFloat: Self = .VK_BORDER_COLOR_FLOAT_CUSTOM_EXT
    static let customExtInt: Self = .VK_BORDER_COLOR_INT_CUSTOM_EXT
}
