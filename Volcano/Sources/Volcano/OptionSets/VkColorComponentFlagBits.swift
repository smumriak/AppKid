//
//  VkColorComponentFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

extension VkColorComponentFlagBits {
    public static let red = VK_COLOR_COMPONENT_R_BIT
    public static let green = VK_COLOR_COMPONENT_G_BIT
    public static let blue = VK_COLOR_COMPONENT_B_BIT
    public static let alpha = VK_COLOR_COMPONENT_A_BIT
}

extension VkColorComponentFlagBits {
    public static let rgba: VkColorComponentFlagBits = [.red, .green, .blue, .alpha]
    public static let rgb: VkColorComponentFlagBits = [.red, .green, .blue]
}
