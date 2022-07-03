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

public final class Image {
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

        var url = bundle.url(forResource: fileName, withExtension: fileExtension)

        let fileManager = FileManager.default

        if url == nil {
            let contents = try? fileManager
                .contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
                .filter {
                    let isDirectory = try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory
                    return isDirectory ?? false
                }
                .filter {
                    $0.pathExtension == "resources"
                }

            if let contents = contents {
                for contentURL in contents {
                    let lookupURL = contentURL.appendingPathComponent(fileName, isDirectory: false).appendingPathExtension(fileExtension)
                    if fileManager.fileExists(atPath: lookupURL.absoluteURL.path) {
                        url = lookupURL
                        break
                    }
                }
            }
        }
        
        guard let url = url else {
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

extension Image: _ExpressibleByImageLiteral {
    public convenience init(imageLiteralResourceName: String) {
        self.init(named: imageLiteralResourceName)!
    }
}
