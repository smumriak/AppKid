//
//  TypeConvenience.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension Bool {
    public var vkBool: VkBool32 { self ? VkBool32(VK_TRUE) : VkBool32(VK_FALSE) }
}

extension VkBool32 {
    public var bool: Bool { self == VkBool32(VK_FALSE) ? false : true }
}
