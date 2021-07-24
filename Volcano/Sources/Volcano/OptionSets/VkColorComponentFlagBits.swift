//
//  VkColorComponentFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public typealias VkColorComponentFlagBits = CVulkan.VkColorComponentFlagBits

public extension VkColorComponentFlagBits {
    static let red: Self = .VK_COLOR_COMPONENT_R_BIT
    static let green: Self = .VK_COLOR_COMPONENT_G_BIT
    static let blue: Self = .VK_COLOR_COMPONENT_B_BIT
    static let alpha: Self = .VK_COLOR_COMPONENT_A_BIT
}

public extension VkColorComponentFlagBits {
    static let rgba: Self = [.red, .green, .blue, .alpha]
    static let rgb: Self = [.red, .green, .blue]
}
