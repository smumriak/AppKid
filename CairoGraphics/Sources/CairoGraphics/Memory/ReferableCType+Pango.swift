//
//  RetainableCType+Pango.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 17.02.2020.
//

import Foundation
import CPango
import TinyFoundation

extension PangoLayout: RetainableCType {
    public static var retainFunc: (UnsafeMutablePointer<PangoLayout>?) -> (UnsafeMutablePointer<PangoLayout>?) {
        return {
            return g_object_ref(gpointer($0))?
                .assumingMemoryBound(to: PangoLayout.self)
        }
    }

    public static var releaseFunc: (UnsafeMutablePointer<PangoLayout>?) -> () {
        return {
            return g_object_unref(gpointer($0))
        }
    }
}

extension PangoContext: RetainableCType {
    public static var retainFunc: (UnsafeMutablePointer<PangoContext>?) -> (UnsafeMutablePointer<PangoContext>?) {
        return {
            return g_object_ref(gpointer($0))?
                .assumingMemoryBound(to: PangoContext.self)
        }
    }

    public static var releaseFunc: (UnsafeMutablePointer<PangoContext>?) -> () {
        return {
            return g_object_unref(gpointer($0))
        }
    }
}
