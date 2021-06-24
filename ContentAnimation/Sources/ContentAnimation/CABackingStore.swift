//
//  CABackingStore.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 27.01.2021.
//

import Foundation
import CoreFoundation
import TinyFoundation
import CairoGraphics
import Volcano

public struct CABackingStoreFlags: OptionSet {
    public typealias RawValue = UInt
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public class CABackingStoreContext {
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

public class CABackingStore {
    public fileprivate(set) var frontContext: CGContext
    public fileprivate(set) var backContext: CGContext
    public var frontTexture: Texture?
    public fileprivate(set) var bitsPerComponent: Int
    public fileprivate(set) var bytesPerPixel: Int
    public fileprivate(set) var bytesPerRow: Int
    public fileprivate(set) var colorSpace: CGColorSpace
    public let width: Int
    public let height: Int

    public init(size: CGSize, device: Device, accessQueues: [Queue]) throws {
        width = Int(size.width.rounded(.up))
        height = Int(size.height.rounded(.up))

        bitsPerComponent = 8
        bytesPerPixel = 4
        bytesPerRow = width * bytesPerPixel
        colorSpace = CGColorSpace()

        frontContext = CGContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitMapInfo: [])!
        backContext = CGContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitMapInfo: [])!
    }

    public var image: CGImage? {
        return frontContext.makeImage()
    }

    public func makeTexture(device: Device, accessQueues: [Queue], transferQueue: Queue, transferCommandPool: CommandPool) throws -> Texture {
        let textureDescriptor = TextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8UNorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = .renderTarget

        let result = try device.createTexture(with: textureDescriptor)

        let stagingBufferSize = VkDeviceSize(bytesPerRow * height)
        let stagingBuffer = try Buffer(device: device,
                                       size: stagingBufferSize,
                                       usage: [.transferSource],
                                       memoryProperties: [.hostVisible, .hostCoherent],
                                       accessQueues: accessQueues)

        try stagingBuffer.memoryChunk.withMappedData { data, size in
            data.copyMemory(from: UnsafeRawPointer(frontContext.data!), byteCount: Int(stagingBuffer.size))
        }

        try transferQueue.oneShot(in: transferCommandPool) {
            try $0.copyBuffer(from: stagingBuffer, to: result)
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

public extension CALayer {
    var needsOffscreenRendering: Bool {
        return masksToBounds == true
            || mask != nil
            || shadowOpacity > 0.0
    }
}
