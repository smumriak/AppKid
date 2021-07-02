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

enum ImageFormat {
    case png
    case jpeg
    case gif

    var header: [UInt8] {
        switch self {
            case .png: return [0x89, 0x50, 0x4E, 0x47]
            case .jpeg: return [0xFF, 0xD8]
            case .gif: return [0x47, 0x49, 0x46, 0x38, 0x39, 0x61]
        }
    }

    static var maxHeaderSize: Int = Array<ImageFormat>(arrayLiteral: .png, .jpeg, .gif)
        .map { $0.header.count }
        .reduce(0) { max($0, $1) }
}

public final class CGImage {
    public internal(set) var isMask: Bool
    public internal(set) var width: Int
    public internal(set) var height: Int
    public internal(set) var bitsPerComponent: Int
    public internal(set) var bitsPerPixel: Int
    public internal(set) var bytesPerRow: Int
    public internal(set) var colorSpace: CGColorSpace?

    internal var bitmap: UnsafeMutableRawBufferPointer?

    deinit {
        bitmap?.deallocate()
    }

    public init?(dataProvider: CGDataProvider) {
        guard let data = dataProvider.data else {
            return nil
        }

        let headerSize = ImageFormat.maxHeaderSize
        let header = data[0..<headerSize].map { $0 }

        switch header {
            case ImageFormat.jpeg.header, ImageFormat.png.header, ImageFormat.gif.header:
                var width: Int32 = 0
                var height: Int32 = 0
                var bitsPerPixel: Int32 = 0

                let pixelData: UnsafeMutablePointer<stbi_uc> = data.withUnsafeBytes { pngData in
                    let boundData = pngData.bindMemory(to: stbi_uc.self)
                    return stbi_load_from_memory(boundData.baseAddress!, Int32(pngData.count), &width, &height, &bitsPerPixel, 4)
                }

                self.isMask = false
                self.width = Int(width)
                self.height = Int(height)
                self.bitsPerComponent = 8
                self.bitsPerPixel = Int(bitsPerPixel)
                self.bytesPerRow = Int(width) * Int(bitsPerPixel)

                self.bitmap = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(pixelData), count: self.width)

            default:
                return nil
        }

        return nil
    }

    internal init?(context: CGContext) {
        guard let pixelData = context.data else {
            return nil
        }

        let size = context.height * context.bytesPerRow

        let copyData = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1)
        copyData.copyMemory(from: pixelData, byteCount: size)

        self.bitmap = UnsafeMutableRawBufferPointer(start: copyData, count: size)

        self.isMask = false
        self.width = context.width
        self.height = context.height
        self.bitsPerComponent = context.bitsPerComponent
        self.bitsPerPixel = context.bitsPerPixel
        self.bytesPerRow = context.bytesPerRow
    }
}
