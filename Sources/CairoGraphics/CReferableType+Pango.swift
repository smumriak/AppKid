//
//  CReferableType+Pango.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 17/2/20.
//

import Foundation
import CPango

extension PangoLayout: CReferableType {
    public var retainFunc: (UnsafeMutablePointer<PangoLayout>?) -> (UnsafeMutablePointer<PangoLayout>?) {
        return {
            return g_object_ref(UnsafeMutableRawPointer($0))?
                .assumingMemoryBound(to: PangoLayout.self)
        }
    }

    public var releaseFunc: (UnsafeMutablePointer<PangoLayout>?) -> () {
        return {
            return g_object_unref(UnsafeMutableRawPointer($0))
        }
    }
}
