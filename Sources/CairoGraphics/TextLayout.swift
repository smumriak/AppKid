//
//  TextLayout.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 17/2/20.
//

import Foundation
import CPango
import CCairo

public class TextLayout {
    var layoutPointer: CReferablePointer<PangoLayout>
    var layout: UnsafeMutablePointer<PangoLayout> {
        get {
            return layoutPointer.pointer
        }
        set {
            layoutPointer.pointer = newValue
        }
    }
    var context: CGContext

    public init(context: CGContext) {
        self.context = context
        let layout = pango_cairo_create_layout(context._context)!
        layoutPointer = CReferablePointer(with: layout)
        layout.release()
    }

    public func render(string: String, in rect: CGRect) {
        let fontDescription = pango_font_description_new();
        pango_font_description_set_family(fontDescription, "serif");
        pango_font_description_set_weight(fontDescription, PANGO_WEIGHT_BOLD);
        pango_font_description_set_absolute_size(fontDescription, Double(17 * PANGO_SCALE));

        pango_layout_set_font_description(layout, fontDescription)
        pango_layout_set_wrap(layout, PANGO_WRAP_WORD)

        pango_font_description_free(fontDescription)

        pango_cairo_update_layout(context._context, layout)

        pango_layout_set_text(layout, string.cString(using: .utf8), -1)

        pango_layout_set_width(layout, Int32(rect.width.rounded(.down)) * PANGO_SCALE)
        pango_layout_set_height(layout, Int32(rect.height.rounded(.down)) * PANGO_SCALE)
        pango_layout_set_alignment(layout, PANGO_ALIGN_CENTER)

        pango_layout_set_ellipsize(layout, PANGO_ELLIPSIZE_END)

        context.move(to: rect.origin)
        cairo_set_source_rgb(context._context, 1.0, 0.0, 0.0)
        pango_cairo_show_layout(context._context, layout)
    }
}
