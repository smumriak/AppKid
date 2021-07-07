//
//  VkBorderColor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021
//

import CVulkan

public typealias VkBorderColor = CVulkan.VkBorderColor

public extension VkBorderColor {
    static let transparentBlackFloat: VkBorderColor = .VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK
    static let transparentBlackInt: VkBorderColor = .VK_BORDER_COLOR_INT_TRANSPARENT_BLACK
    static let opaqueBlackFloat: VkBorderColor = .VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK
    static let opaqueBlackInt: VkBorderColor = .VK_BORDER_COLOR_INT_OPAQUE_BLACK
    static let opaqueWhiteFloat: VkBorderColor = .VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE
    static let opaqueWhiteInt: VkBorderColor = .VK_BORDER_COLOR_INT_OPAQUE_WHITE
    static let customExtFloat: VkBorderColor = .VK_BORDER_COLOR_FLOAT_CUSTOM_EXT
    static let customExtInt: VkBorderColor = .VK_BORDER_COLOR_INT_CUSTOM_EXT
}
