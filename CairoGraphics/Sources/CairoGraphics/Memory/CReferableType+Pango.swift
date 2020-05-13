//
//  CReferableType+Pango.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 17.02.2020.
//

import Foundation
import CPango

extension PangoLayout: CReferableType {
    public var retainFunc: (UnsafeMutablePointer<PangoLayout>?) -> (UnsafeMutablePointer<PangoLayout>?) {
        return {
            return g_object_ref(gpointer($0))?
                .assumingMemoryBound(to: PangoLayout.self)
        }
    }

    public var releaseFunc: (UnsafeMutablePointer<PangoLayout>?) -> () {
        return {
            return g_object_unref(gpointer($0))
        }
    }
}

extension PangoContext: CReferableType {
    public var retainFunc: (UnsafeMutablePointer<PangoContext>?) -> (UnsafeMutablePointer<PangoContext>?) {
        return {
            return g_object_ref(gpointer($0))?
                .assumingMemoryBound(to: PangoContext.self)
        }
    }

    public var releaseFunc: (UnsafeMutablePointer<PangoContext>?) -> () {
        return {
            return g_object_unref(gpointer($0))
        }
    }
}
