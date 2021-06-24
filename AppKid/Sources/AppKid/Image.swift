//
//  Image.swift
//  AppKid
//
//  Created by Serhii Mumriak on 07.01.2021.
//

import Foundation
import TinyFoundation
import CairoGraphics

public final class Image: NSObject {
    public internal(set) var cgImage: CGImage?
    public internal(set) var images: [Image]?

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
}
