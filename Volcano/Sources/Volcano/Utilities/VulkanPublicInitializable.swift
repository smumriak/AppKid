//
//  VulkanPublicInitializable.swift
//  Volcano
//
//  Created by Serhii Mumriak on 25.01.2021.
//

import Foundation
import TinyFoundation
import CVulkan
import SimpleGLM

extension VkPhysicalDeviceProperties: PublicInitializable {}
extension VkPhysicalDeviceMemoryProperties: PublicInitializable {}
extension VkQueueFamilyProperties: PublicInitializable {}
extension VkSurfaceFormatKHR: PublicInitializable {}
extension VkPresentModeKHR: PublicInitializable {
    public init() {
        self = .immediate
    }
}
