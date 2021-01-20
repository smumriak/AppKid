//
//  CGImage.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 27.12.2020.
//

import Foundation
import CoreFoundation
import TinyFoundation
import STBImageRead

public final class CGImage {
    // public internal(set) var isMask: Bool
    // public internal(set) var width: Int
    // public internal(set) var height: Int
    // public internal(set) var bitsPerComponent: Int
    // public internal(set) var bitsPerPixel: Int
    // public internal(set) var bytesPerRow: Int
    // public internal(set) var colorSpace: CGColorSpace?

    // internal var bitmap: UnsafeMutableRawBufferPointer?

    // deinit {
    //     bitmap?.deallocate()
    // }

    // public init?(pngData: Data) {
    //     var width: Int32 = 0
    //     var height: Int32 = 0
    //     var numberOfChannels: Int32 = 0

    //     let pixelData: UnsafeMutablePointer<stbi_uc> = pngData.withUnsafeBytes { pngData in
    //         let boundData = pngData.bindMemory(to: stbi_uc.self)
    //         return stbi_load_from_memory(boundData.baseAddress!, Int32(pngData.count), &width, &height, &numberOfChannels, 4)
    //     }

    //     self.isMask = false
    //     self.width = Int(width)
    //     self.height = Int(height)
    //     self.bitsPerComponent = 8
    //     self.bitsPerPixel = 32
    //     self.bytesPerRow = self.width * bitsPerPixel

    //     self.bitmap = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(pixelData), count: self.width)
    // }
}
