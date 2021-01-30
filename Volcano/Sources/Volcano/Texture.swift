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
    var sampleCount: VkSampleCountFlagBits { get }
    var arrayLength: Int { get }
    var usage: TextureUsage { get }
    var swizzle: VkComponentMapping { get }
    var tiling: VkImageTiling { get }

    var accessQueueFamiliesIndices: [CUnsignedInt] { get }
    var isDepthTexture: Bool { get }
    var isStencilTexture: Bool { get }
    var layout: VkImageLayout { get }

    var image: Image { get }
    var imageView: ImageView { get }
    
    func makeTextureView(pixelFormat: VkFormat) throws -> Texture
}

internal class SwapchainTexture: Texture {
    let swapchain: Swapchain

    let textureType: VkImageViewType = .type2D
    let pixelFormat: VkFormat
    let width: Int
    let height: Int
    let depth: Int = 1
    let mipmapLevelCount: Int = 0
    let sampleCount: VkSampleCountFlagBits = .one
    let arrayLength: Int = 0
    let usage: TextureUsage = .renderTarget
    let swizzle: VkComponentMapping = .identity
    let tiling: VkImageTiling = .optimal

    let accessQueueFamiliesIndices: [CUnsignedInt] = []
    let isDepthTexture: Bool = false
    let isStencilTexture: Bool = false
    var layout: VkImageLayout = .undefined

    let image: Image
    let imageView: ImageView

    init(swapchain: Swapchain, imageIndex: Int) throws {
        pixelFormat = swapchain.imageFormat
        self.swapchain = swapchain

        image = try Image(device: swapchain.device, swapchainImageHandle: swapchain.rawImages[imageIndex], format: pixelFormat)

        let imageViewDescriptor = ImageViewDescriptor()
        imageViewDescriptor.flags = []
        imageViewDescriptor.type = textureType
        imageViewDescriptor.format = pixelFormat
        imageViewDescriptor.componentMapping = .identity
        imageViewDescriptor.aspect = .color
        imageViewDescriptor.baseMipLevel = 0
        imageViewDescriptor.levelCount = 1
        imageViewDescriptor.baseArrayLayer = 0
        imageViewDescriptor.layerCount = 1

        imageView = try ImageView(image: image, descriptor: imageViewDescriptor)

        width = Int(swapchain.size.width)
        height = Int(swapchain.size.height)
    }

    func makeTextureView(pixelFormat: VkFormat) throws -> Texture {
        fatalError()
    }
}

internal class GenericTexture: Texture {
    let memory: MemoryChunk

    let textureType: VkImageViewType = .type2D
    let pixelFormat: VkFormat
    let width: Int
    let height: Int
    let depth: Int = 0
    let mipmapLevelCount: Int = 0
    let sampleCount: VkSampleCountFlagBits = .one
    let arrayLength: Int = 0
    let usage: TextureUsage = .renderTarget
    let swizzle: VkComponentMapping = .identity
    let tiling: VkImageTiling = .optimal

    let accessQueueFamiliesIndices: [CUnsignedInt] = []
    let isDepthTexture: Bool = false
    let isStencilTexture: Bool = false
    var layout: VkImageLayout = .undefined

    let image: Image
    let imageView: ImageView

    init(device: Device, descriptor: TextureDescriptor) throws {
        image = try Image(device: device, descriptor: descriptor.imageDescriptor)
        imageView = try ImageView(image: image, descriptor: descriptor.imageViewDescriptor)
        fatalError()
    }

    func makeTextureView(pixelFormat: VkFormat) throws -> Texture {
        fatalError()
    }
}

internal class BufferTexture: Texture {
    let buffer: Buffer

    let textureType: VkImageViewType = .type2D
    let pixelFormat: VkFormat = .b8g8r8a8UInt
    let width: Int = 0
    let height: Int = 0
    let depth: Int = 0
    let mipmapLevelCount: Int = 0
    let sampleCount: VkSampleCountFlagBits = .one
    let arrayLength: Int = 0
    let usage: TextureUsage = .renderTarget
    let swizzle: VkComponentMapping = .identity
    let tiling: VkImageTiling = .optimal

    let accessQueueFamiliesIndices: [CUnsignedInt] = []
    let isDepthTexture: Bool = false
    let isStencilTexture: Bool = false
    var layout: VkImageLayout = .undefined

    let image: Image
    let imageView: ImageView

    init(image: Image, imageView: ImageView, buffer: Buffer) throws {
        self.buffer = buffer
        self.image = image
        self.imageView = imageView
    }

    func makeTextureView(pixelFormat: VkFormat) throws -> Texture {
        fatalError()
    }
}
