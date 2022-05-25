//
//  Image.swift
//  AppKid
//
//  Created by Serhii Mumriak on 07.01.2021.
//

import Foundation
import TinyFoundation
import CairoGraphics

#if os(macOS)
    import class CairoGraphics.CGImage
#endif

public final class Image: NSObject {
    public internal(set) var cgImage: CGImage?
    public internal(set) var images: [Image]?

    public var size: CGSize {
        if let cgImage = cgImage {
            return CGSize(width: cgImage.width, height: cgImage.height)
        } else {
            return .zero
        }
    }

    public init?(named name: String, in bundle: Bundle = Bundle.main) {
        let nameCasted = name as NSString
        
        let fileName = nameCasted.deletingPathExtension
        var fileExtension = nameCasted.pathExtension
        if fileExtension.isEmpty {
            fileExtension = "png"
        }
        
        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
            return nil
        }

        guard let dataProvider = CGDataProvider(url: url) else {
            return nil
        }

        cgImage = CGImage(dataProvider: dataProvider)
    }

    public init?(data: Data) {
        guard let dataProvider = CGDataProvider(data: data) else {
            return nil
        }

        cgImage = CGImage(dataProvider: dataProvider)
    }

    public init?(contentsOfFile path: String) {
        let url = URL(fileURLWithPath: path, isDirectory: false)

        guard let dataProvider = CGDataProvider(url: url) else {
            return nil
        }

        cgImage = CGImage(dataProvider: dataProvider)
    }
}
