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
import Volcano

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

    public func createBackingStore(size: CGSize) throws -> CABackingStore {
        return try CABackingStore(size: size, device: device, accessQueues: accessQueues)
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

    public init(size: CGSize, device: Device, accessQueues: [Queue]) throws {
        width = Int(size.width.rounded(.up))
        height = Int(size.height.rounded(.up))

        bitsPerComponent = 8
        bytesPerPixel = 4
        bytesPerRow = width * bytesPerPixel
        colorSpace = CGColorSpace()

        let alphaInfo: CGContext.CGImageAlphaInfo = .premultipliedFirst
        let pixelFormat: CGContext.CGImagePixelFormatInfo = .packed

        let bitmapInfo: CGContext.CGBitmapInfo = [alphaInfo.bitmapInfo, pixelFormat.bitmapInfo]

        frontContext = CGContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace, bitmapInfo: bitmapInfo)!
        backContext = CGContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace, bitmapInfo: bitmapInfo)!
    }

    public var image: CGImage? {
        return frontContext.makeImage()
    }

    public func makeTexture(device: Device, graphicsQueue: Queue, commandPool: CommandPool) throws -> Texture {
        let textureDescriptor = TextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8UNorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.tiling = .optimal
        textureDescriptor.memoryProperties = .deviceLocal

        let result = try device.createTexture(with: textureDescriptor)

        let stagingBufferSize = VkDeviceSize(bytesPerRow * height)
        let stagingBuffer = try Buffer(device: device,
                                       size: stagingBufferSize,
                                       usage: [.transferSource],
                                       memoryProperties: [.hostVisible, .hostCoherent],
                                       accessQueues: [graphicsQueue])

        try stagingBuffer.memoryChunk.withMappedData { data, size in
            data.copyMemory(from: UnsafeRawPointer(frontContext.data!), byteCount: Int(stagingBuffer.size))
        }

        try graphicsQueue.oneShot(in: commandPool) {
            try $0.transitionLayout(for: result, newLayout: .transferDestinationOptimal)
            try $0.copyBuffer(from: stagingBuffer, to: result, texelsPerRow: CUnsignedInt(frontContext.width), height: CUnsignedInt(frontContext.height))
            try $0.transitionLayout(for: result, newLayout: .shaderReadOnlyOptimal)
        }

        return result
    }

    public func update(width: Int, height: Int, flags: CABackingStoreFlags = [], callback: (_ context: CGContext) -> ()) {
        callback(backContext)
        Swift.swap(&frontContext, &backContext)
    }

    public func fits(size: CGSize) -> Bool {
        return width == Int(size.width.rounded(.up)) && height == Int(size.height.rounded(.up))
    }
}

internal extension CALayer {
    var needsOffscreenRendering: Bool {
        return masksToBounds == true
            || mask != nil
            || shadowOpacity > 0.0
    }
}
