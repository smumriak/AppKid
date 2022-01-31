//
//  CABackingStore.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 27.01.2021.
//

import Foundation
import CoreFoundation
import TinyFoundation
@_spi(AppKid) import CairoGraphics
@_spi(AppKid) import Volcano

#if os(macOS)
    import class CairoGraphics.CGContext
    import class CairoGraphics.CGColorSpace
    import class CairoGraphics.CGImage
#endif

@_spi(AppKid) public struct CABackingStoreFlags: OptionSet {
    public typealias RawValue = UInt
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

@_spi(AppKid) public class CABackingStoreContext {
    public let device: Device
    public let accessQueues: [Queue]

    internal init(device: Device, accessQueues: [Queue]) {
        self.device = device
        self.accessQueues = accessQueues
    }

    public static var global: CABackingStoreContext! = nil

    public static func setupGlobalContext(device: Device, accessQueues: [Queue]) {
        guard Self.global == nil else {
            fatalError("Global backing store context has already been set up")
        }

        CABackingStoreContext.global = CABackingStoreContext(device: device, accessQueues: accessQueues)
    }

    public func createBackingStore(size: CGSize, scale: CGFloat) throws -> CABackingStore {
        return try CABackingStore(size: size, scale: scale, device: device, accessQueues: accessQueues)
    }
}

@_spi(AppKid) public class CABackingStore {
    public fileprivate(set) var frontContext: CGContext
    public fileprivate(set) var backContext: CGContext
    public var frontTexture: Texture?
    public fileprivate(set) var bitsPerComponent: Int
    public fileprivate(set) var bytesPerPixel: Int
    public fileprivate(set) var bytesPerRow: Int
    public fileprivate(set) var colorSpace: CGColorSpace
    public let width: Int
    public let height: Int
    public var currentTexture: Texture?

    public init(size: CGSize, scale: CGFloat, device: Device, accessQueues: [Queue]) throws {
        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)

        width = Int(pixelSize.width.rounded(.up))
        height = Int(pixelSize.height.rounded(.up))

        bitsPerComponent = 8
        bytesPerPixel = 4
        bytesPerRow = width * bytesPerPixel
        colorSpace = CGColorSpace()

        let alphaInfo: CGContext.CGImageAlphaInfo = .premultipliedFirst
        let pixelFormat: CGContext.CGImagePixelFormatInfo = .packed

        let bitmapInfo: CGContext.CGBitmapInfo = [alphaInfo.bitmapInfo, pixelFormat.bitmapInfo]

        frontContext = CGContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace, bitmapInfo: bitmapInfo)!
        frontContext.scaleBy(x: scale, y: scale)
        
        backContext = CGContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace, bitmapInfo: bitmapInfo)!
        backContext.scaleBy(x: scale, y: scale)
    }

    public var image: CGImage? {
        return frontContext.makeImage()
    }

    public func makeTexture(renderStack: VolcanoRenderStack, graphicsQueue: Queue, commandPool: CommandPool, semaphores: [TimelineSemaphore] = []) throws -> Texture {
        let device = renderStack.device

        let textureDescriptor = TextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8UNorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.tiling = .optimal
        textureDescriptor.requiredMemoryProperties = .deviceLocal

        let result = try device.createTexture(with: textureDescriptor)

        let stagingBufferDescriptor = BufferDescriptor(stagingWithSize: VkDeviceSize(bytesPerRow * height), accessQueues: [graphicsQueue])

        let stagingBuffer = try device.memoryAllocator.create(with: stagingBufferDescriptor).result

        frontContext.flush()

        try stagingBuffer.memoryChunk.withMappedData { data, size in
            data.copyMemory(from: UnsafeRawPointer(frontContext.data!), byteCount: Int(stagingBuffer.size))
        }

        try graphicsQueue.oneShot(in: commandPool, wait: true, semaphores: semaphores) {
            try $0.performPredefinedLayoutTransition(for: result, newLayout: .transferDestinationOptimal)
            try $0.copyBuffer(from: stagingBuffer, to: result, texelsPerRow: CUnsignedInt(frontContext.width), height: CUnsignedInt(frontContext.height))
            try $0.performPredefinedLayoutTransition(for: result, newLayout: .shaderReadOnlyOptimal)
        }

        return result
    }

    public func updateCurrentTexture(renderStack: VolcanoRenderStack, graphicsQueue: Queue, commandPool: CommandPool, semaphores: [TimelineSemaphore] = []) throws {
        guard let currentTexture = currentTexture else {
            return 
        }

        let device = renderStack.device

        let stagingBufferDescriptor = BufferDescriptor(stagingWithSize: VkDeviceSize(bytesPerRow * height), accessQueues: [graphicsQueue])

        let stagingBuffer = try device.memoryAllocator.create(with: stagingBufferDescriptor).result

        frontContext.flush()

        try stagingBuffer.memoryChunk.withMappedData { data, size in
            data.copyMemory(from: UnsafeRawPointer(frontContext.data!), byteCount: Int(stagingBuffer.size))
        }

        try graphicsQueue.oneShot(in: commandPool, wait: true, semaphores: semaphores) {
            try $0.performPredefinedLayoutTransition(for: currentTexture, newLayout: .transferDestinationOptimal)
            try $0.copyBuffer(from: stagingBuffer, to: currentTexture, texelsPerRow: CUnsignedInt(frontContext.width), height: CUnsignedInt(frontContext.height))
            try $0.performPredefinedLayoutTransition(for: currentTexture, newLayout: .shaderReadOnlyOptimal)
        }
    }

    public func update(flags: CABackingStoreFlags = [], callback: (_ context: CGContext) -> ()) {
        callback(backContext)
        Swift.swap(&frontContext, &backContext)
    }

    public func fits(size: CGSize, scale: CGFloat) -> Bool {
        let scaledSize = size * scale
        return width == Int(scaledSize.width.rounded(.up)) && height == Int(scaledSize.height.rounded(.up))
    }
}

internal extension CALayer {
    var needsOffscreenRendering: Bool {
        return masksToBounds == true
            || mask != nil
            || shadowOpacity > 0.0
    }
}
