//
//  TextureDescriptor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public struct TextureUsage: OptionSet {
    public typealias RawValue = UInt
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public static let unknown: TextureUsage = TextureUsage(rawValue: 0)
    public static let shaderRead: TextureUsage = TextureUsage(rawValue: 1 << 0)
    public static let shaderWrite: TextureUsage = TextureUsage(rawValue: 1 << 1)
    public static let renderTarget: TextureUsage = TextureUsage(rawValue: 1 << 2)
    public static let pixelFormatView: TextureUsage = TextureUsage(rawValue: 1 << 4)
}

public enum StorageMode: UInt {
    case shared
    case managed
    case `private`
    case memoryLess
}

public final class TextureDescriptor: NSObject {
    var textureType: VkImageViewType = .type2D
    var pixelFormat: VkFormat = .rgba8UNorm
    var width: Int = 1
    var height: Int = 1
    var depth: Int = 1
    var mipmapLevelCount: Int = 1
    var sampleCount: Int = 1
    var arrayLength: Int = 1
    var storageMode: StorageMode = .shared
    var allowGPUOptimizedContents: Bool = true
    var usage: TextureUsage = .shaderRead
    var swizzle: VkComponentMapping = .identity
}
