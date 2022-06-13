//
//  Label.swift
//  AppKid
//
//  Created by Serhii Mumriak on 17.02.2020.
//

import Foundation
import CoreFoundation
@_spi(AppKid) import CairoGraphics
import ContentAnimation

#if os(macOS)
    import struct CairoGraphics.CGColor
    import class CairoGraphics.CGContext
#endif

open class Label: View {
    open var text: String? = nil {
        didSet {
            layout.text = text
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    open var textColor: CGColor = .black {
        didSet {
            layout.textColor = textColor
            setNeedsDisplay()
        }
    }

    open var font: Font = .systemFont(ofSize: 17) {
        didSet {
            layout.font = font
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    internal var layout = LabelTextLayout()

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)

        userInteractionEnabled = false
        
        layout.text = text
        layout.textColor = textColor
        layout.font = font
    }

    open override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }

    open override var bounds: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Rendering

    open override func render(in context: CGContext) {
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

    open func renderText(in context: CGContext, textRect: CGRect) {
        layout.render(in: context, rect: textRect)
    }
}
