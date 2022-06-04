//
//  ImageView.swift
//  AppKid
//
//  Created by Serhii Mumriak on 19.05.2022.
//

import Foundation
import TinyFoundation
import CairoGraphics
import ContentAnimation

public class ImageView: View, CALayerDisplayDelegate {
    public var image: Image? {
        didSet {
            setNeedsDisplay()
        }
    }

    public init(image: Image?) {
        var frame: CGRect = .zero

        if let image = image {
            self.image = image
            frame.size = image.size
        }

        super.init(with: frame)

        setNeedsDisplay()
    }

    // MARK: CALayerDisplayDelegate

    public func display(_ layer: CALayer) {
        layer.contents = image?.cgImage
    }
}
