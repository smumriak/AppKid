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

public class FontOptions: HandleStorage<SharedPointer<cairo_font_options_t>> {
    public init() {
        let handlePointer = CopyablePointer(with: cairo_font_options_create())

        super.init(handlePointer: handlePointer)
    }

    public var antialias: cairo_antialias_t {
        get {
            cairo_font_options_get_antialias(handle)
        }
        set {
            cairo_font_options_set_antialias(handle, newValue)
        }
    }

    public var hintStyle: cairo_hint_style_t {
        get {
            cairo_font_options_get_hint_style(handle)
        }
        set {
            cairo_font_options_set_hint_style(handle, newValue)
        }
    }

    public var hintMetrics: cairo_hint_metrics_t {
        get {
            cairo_font_options_get_hint_metrics(handle)
        }
        set {
            cairo_font_options_set_hint_metrics(handle, newValue)
        }
    }

    public var subpixelOrder: cairo_subpixel_order_t {
        get {
            cairo_font_options_get_subpixel_order(handle)
        }
        set {
            cairo_font_options_set_subpixel_order(handle, newValue)
        }
    }
}

@_spi(AppKid) public class TextFontMap: HandleStorage<SharedPointer<PangoFontMap>> {
    public static let `default` = TextFontMap(handlePointer: SharedPointer(with: pango_cairo_font_map_get_default(), deleter: .none))
}

@_spi(AppKid) public class TextContext: HandleStorage<SharedPointer<PangoContext>> {
    public init(with fontMap: TextFontMap = .default) {
        let handlePointer = RetainablePointer(withRetained: pango_font_map_create_context(fontMap.handle)!)

        super.init(handlePointer: handlePointer)
    }

    public var fontOptions: FontOptions? {
        didSet {
            if let fontOptions = fontOptions {
                pango_cairo_context_set_font_options(handle, fontOptions.handle)
            } else {
                pango_cairo_context_set_font_options(handle, nil)
            }
        }
    }

    public func update(with context: CGContext) {
        pango_cairo_update_context(context.context.pointer, handle)
    }
}

@_spi(AppKid) public class TextLayout: HandleStorage<SharedPointer<PangoLayout>> {
    public let context: TextContext
    public init(with context: TextContext) {
        self.context = context
        let handlePointer = RetainablePointer(withRetained: pango_layout_new(context.handle)!)

        super.init(handlePointer: handlePointer)
    }

    public var fontDescription: UnsafePointer<PangoFontDescription> {
        get {
            pango_layout_get_font_description(handle)
        }
        set {
            pango_layout_set_font_description(handle, newValue)
        }
    }

    public var wrap: PangoWrapMode {
        get {
            pango_layout_get_wrap(handle)
        }
        set {
            pango_layout_set_wrap(handle, newValue)
        }
    }

    public var ellipsize: PangoEllipsizeMode {
        get {
            pango_layout_get_ellipsize(handle)
        }
        set {
            pango_layout_set_ellipsize(handle, newValue)
        }
    }

    public var alignment: PangoAlignment {
        get {
            pango_layout_get_alignment(handle)
        }
        set {
            pango_layout_set_alignment(handle, newValue)
        }
    }

    public var width: CInt {
        get {
            pango_layout_get_width(handle)
        }
        set {
            pango_layout_set_width(handle, newValue)
        }
    }

    public var height: CInt {
        get {
            pango_layout_get_height(handle)
        }
        set {
            pango_layout_set_height(handle, newValue)
        }
    }

    public var inkUnitRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_extents(handle, &result, nil)

        return result
    }

    public var logicalUnitRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_extents(handle, nil, &result)

        return result
    }

    public var inkPixelRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_pixel_extents(handle, &result, nil)

        return result
    }

    public var logicalPixelRect: PangoRectangle {
        var result = PangoRectangle()

        pango_layout_get_pixel_extents(handle, nil, &result)

        return result
    }

    public var text: String? {
        get {
            guard let cString = pango_layout_get_text(handle) else {
                return nil
            }

            return String(cString: cString, encoding: .utf8)
        }
        set {
            if let text = newValue {
                pango_layout_set_text(handle, text.cString(using: .utf8), -1)
            } else {
                pango_layout_set_text(handle, nil, 0)
            }
        }
    }

    public var textColor: CGColor? = nil

    public func forceLayout() {
        pango_layout_context_changed(handle)
    }

    public func draw(in context: CGContext) {
        if let textColor = textColor {
            cairo_set_source(context.context.pointer, textColor.cairoPattern.pointer)
        }
        pango_cairo_show_layout(context.context.pointer, handle)
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
