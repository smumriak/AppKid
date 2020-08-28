//
//  CARenderer.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation
import CoreFoundation
import CairoGraphics

open class CARenderer {
    open var layer: CALayer? = nil
    open var bounds: CGRect = .zero

    internal var frameTime: CFTimeInterval = 0.0
    internal var context: CairoGraphics.CGContext

    init(context: CairoGraphics.CGContext) {
        self.context = context
    }

    open func beginFrame(atTime time: TimeInterval) {
        frameTime = time
    }

    open var updateBounds: CGRect {
        return .zero
    }

    open func addUpdate(_ rect: CGRect) {
        bounds = bounds.union(rect)
    }

    open func render() {
    }

    open func nextFrameTime() -> TimeInterval {
        return 0.0
    }

    open func endFrame() {
        frameTime = 0.0
    }
}
