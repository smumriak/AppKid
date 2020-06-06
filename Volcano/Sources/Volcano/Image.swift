//
//  Image.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation

import Foundation
import TinyFoundation
import CVulkan

public final class Image: VulkanDeviceEntity<SmartPointer<VkImage_T>> {
    public let format: VkFormat

    public init(device: Device, format: VkFormat, handle: VkImage) throws {
        self.format = format

        try super.init(device: device, handlePointer: SmartPointer(with: handle))
    }
}
