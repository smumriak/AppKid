//
//  ImageView.swift
//  AppKid
//
//  Created by Serhii Mumriak on 19.05.2022.
//

import Foundation
import TinyFoundation
import CairoGraphics

public class ImageView: View {
    public var image: Image? {
        didSet {
            layer.contents = image?.cgImage
        }
    }

    init(image: Image?) {
        var frame: CGRect = .zero

        if let image = image {
            self.image = image
            frame.size = image.size
        }

        super.init(with: frame)

        layer.contents = image?.cgImage
    }
}
