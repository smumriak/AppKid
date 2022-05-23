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

@_spi(AppKid) open class TextLayout {
    fileprivate var hasChanged = false

    var layout: RetainablePointer<PangoLayout>
    var pangoContext: RetainablePointer<PangoContext>

    open var font: Font = .systemFont(ofSize: 17) {
        didSet {
            pango_layout_set_font_description(layout.pointer, font.cairoFontDescription.pointer)
            hasChanged = true
        }
    }

    open var text: String = "" {
        didSet {
            pango_layout_set_text(layout.pointer, text.cString(using: .utf8), -1)
        }
    }

    open var textColor: CGColor = .black
    
    public init() {
        let defaultFontMap = pango_cairo_font_map_get_default()
        pangoContext = RetainablePointer(withRetained: pango_font_map_create_context(defaultFontMap)!)

        layout = RetainablePointer(withRetained: pango_layout_new(pangoContext.pointer)!)

        pango_layout_set_font_description(layout.pointer, font.cairoFontDescription.pointer)

        let fontOptions = CopyablePointer(with: cairo_font_options_create())
        cairo_font_options_set_antialias(fontOptions.pointer, CAIRO_ANTIALIAS_GOOD)
        cairo_font_options_set_hint_style(fontOptions.pointer, CAIRO_HINT_STYLE_FULL)
        cairo_font_options_set_hint_metrics(fontOptions.pointer, CAIRO_HINT_METRICS_ON)
        cairo_font_options_set_subpixel_order(fontOptions.pointer, CAIRO_SUBPIXEL_ORDER_DEFAULT)
        pango_cairo_context_set_font_options(pangoContext.pointer, fontOptions.pointer)

        pango_layout_set_wrap(layout.pointer, PANGO_WRAP_WORD)
        pango_layout_set_ellipsize(layout.pointer, PANGO_ELLIPSIZE_END)

        pango_layout_set_alignment(layout.pointer, PANGO_ALIGN_CENTER)

        // FIXME: smumriak: Figure out why center alignment produces invalid positions. Use following code to produce debug information for forum questions
        // UPD 17.04.2020. The issue does no longer reproduce. Meanwhile pango update to version 1.44.7 was pushed to pop!_os
        //        var position = PangoRectangle()
        //        pango_layout_index_to_pos(layout, 0, &position)
        //        debugPrint("Position: \(position)")
        //        var pixelWidth: CInt = 0
        //        var pixelHeight: CInt = 0
        //        pango_layout_get_pixel_size(layout, &pixelWidth, &pixelHeight)
        //        debugPrint("Pixel width: \(pixelWidth), pixel height: \(pixelHeight)")
    }

    open func render(in context: CGContext, rect: CGRect) {
        if text.isEmpty { return }

        let cairoContextPointer = context.context.pointer
        
        let newWidth = CInt(rect.width.rounded(.down)) * PANGO_SCALE
        let newHeight = CInt(rect.height.rounded(.down)) * PANGO_SCALE
        
        if newWidth != pango_layout_get_height(layout.pointer) {
            pango_layout_set_width(layout.pointer, newWidth)
            hasChanged = true
        }

        if newHeight != pango_layout_get_height(layout.pointer) {
            pango_layout_set_height(layout.pointer, newHeight)
            hasChanged = true
        }

        if hasChanged {
            pango_cairo_update_context(cairoContextPointer, pangoContext.pointer)
            pango_layout_context_changed(layout.pointer)
            hasChanged = false
        }

        context.move(to: rect.origin)
        cairo_set_source(cairoContextPointer, textColor.cairoPattern.pointer)
        pango_cairo_update_layout(cairoContextPointer, layout.pointer)
        pango_cairo_show_layout(cairoContextPointer, layout.pointer)
    }
}
