//
//  Label.swift
//  AppKid
//
//  Created by Serhii Mumriak on 17.02.2020.
//

import Foundation
import CoreFoundation
import CairoGraphics
import ContentAnimation

open class Label: View {
    open var text: String? = nil {
        didSet {
            layout.text = text ?? ""
        }
    }

    open var textColor: CairoGraphics.CGColor = .black {
        didSet {
            layout.textColor = textColor
        }
    }

    open var font: Font = .systemFont(ofSize: 17) {
        didSet {
            layout.font = font
        }
    }

    internal var layout = TextLayout()

    // MARK: Initialization

    public override init(with frame: CGRect) {
        super.init(with: frame)

        userInteractionEnabled = false
        
        layout.text = text ?? ""
        layout.textColor = textColor
        layout.font = font

        layer.delegate = self
    }

    // MARK: Rendering

    open override func render(in context: CairoGraphics.CGContext) {
        super.render(in: context)

        let textRect = self.textRect(for: bounds, limitedToNumberOfLines: 0)

        renderText(in: context, textRect: textRect)
    }

    public override func draw(_ layer: CALayer, in context: CGContext) {
        let textRect = self.textRect(for: bounds, limitedToNumberOfLines: 0)

        renderText(in: context, textRect: textRect)
    }

    open func textRect(for bounds: CGRect, limitedToNumberOfLines numberOfLinex: Int) -> CGRect {
        return bounds
    }

    open func renderText(in context: CairoGraphics.CGContext, textRect: CGRect) {
        layout.render(in: context, rect: textRect)
    }
}
