//
//  ImageDescriptor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class ImageDescriptor: NSObject {
    var textureType: VkImageViewType = .type2D
    var pixelFormat: VkFormat = .rgba8UNorm
    var width: Int = 1
    var height: Int = 1
    var depth: Int = 1
    var mipmapLevelCount: Int = 1
    var sampleCount: Int = 1
    var arrayLength: Int = 1
    var swizzle: VkComponentMapping = .identity
}
