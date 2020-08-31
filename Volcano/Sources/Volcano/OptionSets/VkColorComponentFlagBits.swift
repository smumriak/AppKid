//
//  VkColorComponentFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public extension VkColorComponentFlagBits {
    static let red = VK_COLOR_COMPONENT_R_BIT
    static let green = VK_COLOR_COMPONENT_G_BIT
    static let blue = VK_COLOR_COMPONENT_B_BIT
    static let alpha = VK_COLOR_COMPONENT_A_BIT
}

public extension VkColorComponentFlagBits {
    static let rgba: VkColorComponentFlagBits = [.red, .green, .blue, .alpha]
    static let rgb: VkColorComponentFlagBits = [.red, .green, .blue]
}
