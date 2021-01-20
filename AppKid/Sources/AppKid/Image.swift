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
        
        guard let path = bundle.path(forResource: fileName, ofType: fileExtension) else {
            return nil
        }

        guard let data = NSData(contentsOfFile: path) else { 
            return nil
        }

        cgImage = CGImage(pngData: data as Data)
    }
}
