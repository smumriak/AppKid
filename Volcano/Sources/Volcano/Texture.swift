//
//  Texture.swift
//  Volcano
//
//  Created by Serhii Mumriak on 11.01.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public protocol Texture {
    var textureType: VkImageViewType { get }
    var pixelFormat: VkFormat { get }
    var width: Int { get }
    var height: Int { get }
    var depth: Int { get }
    var mipmapLevelCount: Int { get }
    var sampleCount: Int { get }
    var arrayLength: Int { get }
    var swizzle: VkComponentMapping { get }
    var isFramebufferOnly: Bool { get }
    
    func mateTextureView(pixelFormat: VkFormat) -> Texture?
}
