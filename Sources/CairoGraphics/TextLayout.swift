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
    var pangoContextPointer: CReferablePointer<PangoContext>
    var pangoContext: UnsafeMutablePointer<PangoContext> {
        get {
            return pangoContextPointer.pointer
        }
        set {
            pangoContextPointer.pointer = newValue
        }
    }
    
    public init() {
        let pangoContext = pango_font_map_create_context(pango_cairo_font_map_get_default())!
        pangoContextPointer = CReferablePointer(with: pangoContext)
        pangoContext.release()

        let layout = pango_layout_new(pangoContext)!
        layoutPointer = CReferablePointer(with: layout)
        layout.release()
    }

    public func render(string: String, in context: CGContext, rect: CGRect) {
        let fontDescription = pango_font_description_new();
        pango_font_description_set_family(fontDescription, "serif");
        pango_font_description_set_weight(fontDescription, PANGO_WEIGHT_BOLD);
        pango_font_description_set_absolute_size(fontDescription, Double(17 * PANGO_SCALE));

        pango_layout_set_font_description(layout, fontDescription)

        pango_font_description_free(fontDescription)

        pango_cairo_update_context(context._context, pangoContext)
        pango_layout_context_changed(layout)

        pango_layout_set_wrap(layout, PANGO_WRAP_WORD)
        pango_layout_set_ellipsize(layout, PANGO_ELLIPSIZE_END)

//        pango_layout_set_alignment(layout, PANGO_ALIGN_CENTER)
        //palkovnik:FIXME: Figure out why center alignment produces invalid positions
        //use following code to produce debug information for forum questions
        //        var position = PangoRectangle()
        //        pango_layout_index_to_pos(layout, 0, &position)
        //        debugPrint("Position: \(position)")
        //        var pixelWidth: CInt = 0
        //        var pixelHeight: CInt = 0
        //        pango_layout_get_pixel_size(layout, &pixelWidth, &pixelHeight)
        //        debugPrint("Pixel width: \(pixelWidth), pixel height: \(pixelHeight)")

        pango_layout_set_width(layout, CInt(rect.width.rounded(.down)) * PANGO_SCALE)
        pango_layout_set_height(layout, CInt(rect.height.rounded(.down)) * PANGO_SCALE)

        pango_layout_set_text(layout, string.cString(using: .utf8), -1)

        context.move(to: rect.origin)
        cairo_set_source_rgb(context._context, 1.0, 0.0, 0.0)
        pango_cairo_show_layout(context._context, layout)
    }
}
