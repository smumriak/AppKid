//
//  Renderer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 22.02.2020.
//

import Foundation
import CairoGraphics

internal final class Renderer {
    let context: CairoGraphics.CGContext

    init(context: CairoGraphics.CGContext) {
        self.context = context
    }

    func render(window: Window) {
        CairoGraphics.CGContext.push(context)
        
        let transform = CairoGraphics.CGAffineTransform(scaleX: window.nativeWindow.displayScale, y: window.nativeWindow.displayScale)

        render(view: window, in: context, with: transform)

        CairoGraphics.CGContext.pop()

        window.nativeWindow.flush()
    }
    
    fileprivate func render(view: View, in context: CairoGraphics.CGContext, with transform: CairoGraphics.CGAffineTransform) {
        context.saveState()

        let transform = view.transform
            .concatenating(transform.translatedBy(x: view.center.x, y: view.center.y))
            .translatedBy(x: -view.bounds.width * 0.5, y: -view.bounds.height * 0.5)

        context.ctm = transform

        if view.masksToBounds {
            context.addRect(view.bounds)
            context.clip()
        }

        if let window = view.window {
            view.render(in: context)

            for subview in view.subviews {
                let frameInWindowSpace = view.convert(subview.frame, to: window)
                
                if frameInWindowSpace.intersects(window.bounds) {
                    render(view: subview, in: context, with: transform)
                }
            }
        }

        context.restoreState()
    }
}
