//
//  VulkanImage.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation

import Foundation
import TinyFoundation
import CVulkan

public final class VulkanImage: VulkanDeviceEntity<SimplePointer<VkImage_T>> {
    public let format: VkFormat

    public init(device: VulkanDevice, format: VkFormat, handle: VkImage) throws {
        self.format = format

        try super.init(device: device, handlePointer: SimplePointer(with: handle))
    }
}
