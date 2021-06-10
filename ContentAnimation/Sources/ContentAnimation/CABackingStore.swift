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

public class CABackingStore {
    public fileprivate(set) var bitmapContext: CGContext
    public fileprivate(set) var backTexture: Texture
    public fileprivate(set) var frontTexture: Texture
    public let width: Int
    public let height: Int

    public init(size: CGSize, device: Device) throws {
        width = Int(size.width.rounded(.up))
        height = Int(size.height.rounded(.up))

        let bitsPerComponent: Int = 8
        let bytesPerPixel: Int = 4
        let bytesPerRow: Int = width * bytesPerPixel
        let colorSpace = CGColorSpace()

        bitmapContext = CGContext(width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitMapInfo: [])!

        let textureDescriptor = TextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8UNorm, width: width, height: height, mipmapped: false)
        frontTexture = try device.createTexture(with: textureDescriptor)
        backTexture = try device.createTexture(with: textureDescriptor)
    }

    public func swap() {
        Swift.swap(&frontTexture, &backTexture)
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

public class CGBackingStoreContext: CGContext {
    public let backingStore: CABackingStore

    public init(backingStore: CABackingStore) {
        self.backingStore = backingStore

        super.init(backingStore.bitmapContext)
    }

    public func createDrawOperations() {
    }
}
