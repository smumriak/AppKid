//
//  Texture.swift
//  Volcano
//
//  Created by Serhii Mumriak on 11.01.2020.
//

import Foundation
import TinyFoundation
import CVulkan

internal var globalTextureCounter: UInt = 0
internal var globalTextureCounterLock = NSLock()

internal func grabAvailableGlobalTextureIdentifier() -> UInt {
    return globalTextureCounterLock.synchronized {
        globalTextureCounter += 1
        return globalTextureCounter
    }
}

public protocol Texture: AnyObject {
    var device: Device { get }
    var textureIdentifier: UInt { get }
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
    var layout: VkImageLayout { get @_spi(AppKid) set }

    var image: Image { get }
    var imageView: ImageView { get }

    func makeTextureView(pixelFormat: VkFormat) throws -> Texture

    @_spi(AppKid) var hashable: AnyHashable { get }
    @_spi(AppKid) var deinitHooks: [() -> ()] { get set }
}

@_spi(AppKid) public extension Texture {
    func hash(into hasher: inout Hasher) {
        textureIdentifier.hash(into: &hasher)
        image.hash(into: &hasher)
        imageView.hash(into: &hasher)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.textureIdentifier == rhs.textureIdentifier
            && lhs.image == rhs.image
            && lhs.imageView == rhs.imageView
    }

    @_spi(AppKid) func addDeinitHook(_ hook: @escaping () -> ()) {
        deinitHooks.append(hook)
    }
}

@_spi(AppKid) public extension Texture where Self: Hashable {
    var hashable: AnyHashable {
        return self
    }
}

@_spi(AppKid) public extension Texture {
    @_spi(AppKid) func setLayout(_ layout: VkImageLayout) {
        self.layout = layout
    }
}

public extension Texture {
    var extent: VkExtent3D { return VkExtent3D(width: CUnsignedInt(width), height: CUnsignedInt(height), depth: CUnsignedInt(depth)) }
}

internal class SwapchainTexture: Texture, Hashable {
    let device: Device
    let swapchain: Swapchain

    let textureIdentifier: UInt

    let textureType: VkImageViewType = .twoDimensions
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

    var deinitHooks: [() -> ()] = []

    deinit {
        deinitHooks.forEach { $0() }
    }

    init(swapchain: Swapchain, imageIndex: Int) throws {
        device = swapchain.device

        pixelFormat = swapchain.imageFormat
        self.swapchain = swapchain

        image = try Image(device: device, swapchainImageHandle: swapchain.rawImages[imageIndex], format: pixelFormat)

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

        // has to happen in the very end of init!
        textureIdentifier = grabAvailableGlobalTextureIdentifier()
    }

    func makeTextureView(pixelFormat: VkFormat) throws -> Texture {
        fatalError()
    }
}

internal class GenericTexture: Texture, Hashable {
    let device: Device
    let memoryChunk: MemoryChunk

    let textureIdentifier: UInt

    let textureType: VkImageViewType
    let pixelFormat: VkFormat
    let width: Int
    let height: Int
    let depth: Int
    let mipmapLevelCount: Int
    let sampleCount: VkSampleCountFlagBits
    let arrayLength: Int
    let usage: TextureUsage
    let swizzle: VkComponentMapping
    let tiling: VkImageTiling

    let accessQueueFamiliesIndices: [CUnsignedInt]
    let isDepthTexture: Bool
    let isStencilTexture: Bool
    var layout: VkImageLayout = .undefined

    let image: Image
    let imageView: ImageView

    var deinitHooks: [() -> ()] = []

    deinit {
        deinitHooks.forEach { $0() }
    }
    
    init(device: Device, descriptor: TextureDescriptor) throws {
        self.device = device

        let imageDescriptor = descriptor.imageDescriptor

        let (image, memoryChunk) = try device.memoryAllocator.create(with: imageDescriptor)

        // let image = try Image(device: device, descriptor: imageDescriptor)
        
        // let memoryChunk = try device.memoryAllocator.allocate(for: image.handle, descriptor: imageDescriptor)

        try memoryChunk.bind(to: image)

        let imageView = try ImageView(image: image, descriptor: descriptor.imageViewDescriptor)
        
        self.memoryChunk = memoryChunk
        self.image = image
        self.imageView = imageView

        self.textureType = descriptor.textureType
        self.pixelFormat = descriptor.pixelFormat
        self.width = descriptor.width
        self.height = descriptor.height
        self.depth = descriptor.depth
        self.mipmapLevelCount = descriptor.mipmapLevelCount
        self.sampleCount = descriptor.sampleCount
        self.arrayLength = descriptor.arrayLength
        self.usage = descriptor.usage
        self.swizzle = descriptor.swizzle
        self.tiling = descriptor.tiling

        self.accessQueueFamiliesIndices = descriptor.accessQueueFamiliesIndices
        self.isDepthTexture = descriptor.isDepthTexture
        self.isStencilTexture = descriptor.isStencilTexture
        self.layout = descriptor.initialLayout

        // has to happen in the very end of init!
        textureIdentifier = grabAvailableGlobalTextureIdentifier()
    }

    func makeTextureView(pixelFormat: VkFormat) throws -> Texture {
        fatalError()
    }
}

internal class BufferTexture: Texture, Hashable {
    let device: Device
    let buffer: Buffer

    let textureIdentifier: UInt

    let textureType: VkImageViewType = .twoDimensions
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

    var deinitHooks: [() -> ()] = []

    deinit {
        deinitHooks.forEach { $0() }
    }

    init(image: Image, imageView: ImageView, buffer: Buffer) throws {
        device = image.device
        
        self.buffer = buffer
        self.image = image
        self.imageView = imageView

        // has to happen in the very end of init!
        textureIdentifier = grabAvailableGlobalTextureIdentifier()
    }

    func makeTextureView(pixelFormat: VkFormat) throws -> Texture {
        fatalError()
    }
}

public extension Device {
    func createTexture(with descriptor: TextureDescriptor) throws -> Texture {
        return try GenericTexture(device: self, descriptor: descriptor)
    }
}
