//
//  TextLayout.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 17.02.2020.
//

import Foundation
import CPango
import CCairo
import TinyFoundation

public class FontOptions: SharedPointerStorage<cairo_font_options_t> {
    public init() {
        let handle = CopyablePointer(with: cairo_font_options_create())

        super.init(handle: handle)
    }

    public var antialias: cairo_antialias_t {
        get {
            cairo_font_options_get_antialias(pointer)
        }
        set {
            cairo_font_options_set_antialias(pointer, newValue)
        }
    }

    public var hintStyle: cairo_hint_style_t {
        get {
            cairo_font_options_get_hint_style(pointer)
        }
        set {
            cairo_font_options_set_hint_style(pointer, newValue)
        }
    }

    public var hintMetrics: cairo_hint_metrics_t {
        get {
            cairo_font_options_get_hint_metrics(pointer)
        }
        set {
            cairo_font_options_set_hint_metrics(pointer, newValue)
        }
    }

    public var subpixelOrder: cairo_subpixel_order_t {
        get {
            cairo_font_options_get_subpixel_order(pointer)
        }
        set {
            cairo_font_options_set_subpixel_order(pointer, newValue)
        }
    }
}

@_spi(AppKid) public class TextFontMap: SharedPointerStorage<PangoFontMap> {
    public static let `default` = TextFontMap(handle: SharedPointer(with: pango_cairo_font_map_get_default(), deleter: .none))
}

@_spi(AppKid) public class TextContext: SharedPointerStorage<PangoContext> {
    public init(with fontMap: TextFontMap = .default) {
        let handle = RetainablePointer(withRetained: pango_font_map_create_context(fontMap.pointer)!)

        super.init(handle: handle)
    }

    public var fontOptions: FontOptions? {
        didSet {
            if let fontOptions = fontOptions {
                pango_cairo_context_set_font_options(pointer, fontOptions.pointer)
            } else {
                pango_cairo_context_set_font_options(pointer, nil)
            }
        }
    }

    public func update(with context: CGContext) {
        pango_cairo_update_context(context.context.pointer, pointer)
    }
}

@_spi(AppKid) public class TextLayout: SharedPointerStorage<PangoLayout> {
    public let context: TextContext
    public init(with context: TextContext) {
        self.context = context
        let pointer = RetainablePointer(withRetained: pango_layout_new(context.pointer)!)

        super.init(handle: pointer)
    }

    public var fontDescription: UnsafePointer<PangoFontDescription> {
        get {
            pango_layout_get_font_description(pointer)
        }
        set {
            pango_layout_set_font_description(pointer, newValue)
        }
    }

    public var wrap: PangoWrapMode {
        get {
            pango_layout_get_wrap(pointer)
        }
        set {
            pango_layout_set_wrap(pointer, newValue)
        }
    }

    public var ellipsize: PangoEllipsizeMode {
        get {
            pango_layout_get_ellipsize(pointer)
        }
        set {
            pango_layout_set_ellipsize(pointer, newValue)
        }
    }

    public var alignment: PangoAlignment {
        get {
            pango_layout_get_alignment(pointer)
        }
        set {
            pango_layout_set_alignment(pointer, newValue)
        }
    }

    public var width: CInt {
        get {
            pango_layout_get_width(pointer)
        }
        set {
            pango_layout_set_width(pointer, newValue)
        }
    }

    public var height: CInt {
        get {
            pango_layout_get_height(pointer)
        }
        set {
            pango_layout_set_height(pointer, newValue)
        }
    }

    public var inkUnitRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_extents(pointer, &result, nil)

        return result
    }

    public var logicalUnitRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_extents(pointer, nil, &result)

        return result
    }

    public var inkPixelRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_pixel_extents(pointer, &result, nil)

        return result
    }

    public var logicalPixelRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_pixel_extents(pointer, nil, &result)

        return result
    }

    public var text: String? {
        get {
            guard let cString = pango_layout_get_text(pointer) else {
                return nil
            }

            return String(cString: cString, encoding: .utf8)
        }
        set {
            if let text = newValue {
                pango_layout_set_text(pointer, text.cString(using: .utf8), -1)
            } else {
                pango_layout_set_text(pointer, nil, 0)
            }
        }
    }

    public var textColor: CGColor? = nil

    public func forceLayout() {
        pango_layout_context_changed(pointer)
    }

    public func draw(in context: CGContext) {
        if let textColor = textColor {
            cairo_set_source(context.context.pointer, textColor.cairoPattern.pointer)
        }
        pango_cairo_show_layout(context.context.pointer, pointer)
    }
}

@_spi(AppKid) open class LabelTextLayout {
    fileprivate var hasChanged = false

    public private(set) var layout: TextLayout
    public private(set) var textContext: TextContext

    open var font: Font = .systemFont(ofSize: 17) {
        didSet {
            layout.fontDescription = UnsafePointer(font.cairoFontDescription.pointer)
            hasChanged = true
        }
    }

    open var text: String? {
        get {
            layout.text
        }
        set {
            layout.text = newValue
        }
    }

    open var textColor: CGColor? {
        get {
            layout.textColor
        }
        set {
            layout.textColor = newValue
        }
    }
    
    public init() {
        textContext = TextContext()
        layout = TextLayout(with: textContext)
        layout.fontDescription = UnsafePointer(font.cairoFontDescription.pointer)

        let fontOptions = FontOptions()
        fontOptions.antialias = .good
        fontOptions.hintStyle = .full
        fontOptions.hintMetrics = .on
        fontOptions.subpixelOrder = .default
        textContext.fontOptions = fontOptions

        layout.wrap = .word
        layout.ellipsize = .end
        layout.alignment = .center
    }

    open func render(in context: CGContext, rect: CGRect) {
        guard let text = text, text.isEmpty == false else {
            return
        }

        var rect = rect

        let width = rect.width.rounded(.up).pangoUnits
        let height = rect.height.rounded(.up).pangoUnits
        
        if width != layout.width {
            layout.width = width
            hasChanged = true
        }

        if height != layout.height {
            layout.height = height
            hasChanged = true
        }

        if hasChanged {
            textContext.update(with: context)
            layout.forceLayout()
            hasChanged = false
        }

        let delta = rect.midY - layout.logicalPixelRect.cgRect.midY
        if delta > 0 {
            rect.origin.y += delta
        }

        context.move(to: rect.origin)
        layout.draw(in: context)
    }
}

public extension PangoRectangle {
    @_transparent
    var cgRect: CGRect {
        return CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
    }
}

public extension BinaryFloatingPoint {
    @_transparent
    var pangoUnits: CInt {
        return pango_units_from_double(Double(self))
    }
}
