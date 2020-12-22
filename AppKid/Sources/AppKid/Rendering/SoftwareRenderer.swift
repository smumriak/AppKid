//
//  SoftwareRenderer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 22.02.2020.
//

import Foundation
import CairoGraphics

internal final class SoftwareRenderer: NSObject {
    let context: CairoGraphics.CGContext

    init(context: CairoGraphics.CGContext) {
        self.context = context

        super.init()
    }

    func render(window: Window) {
        CairoGraphics.CGContext.push(context)
        
        let transform = CGAffineTransform(scaleX: window.nativeWindow.displayScale, y: window.nativeWindow.displayScale)

        render(view: window, in: context, with: transform)

        CairoGraphics.CGContext.pop()
    }
    
    fileprivate func render(view: View, in context: CairoGraphics.CGContext, with transform: CairoGraphics.CGAffineTransform) {
        context.saveState()

        let bounds = view.bounds
        let center = view.center

        // palkovnik:I know it looks like unneeded work with all translations, especially the last two. But it's the easiest way to document what's happening. If this will be a performance bottleneck (lol, there are probably more performance heavy code here) i'll remove it
        let transform = CairoGraphics.CGAffineTransform.identity
            .concatenating(CGAffineTransform(translationX: -bounds.minX, y: -bounds.minY))
            .concatenating(CGAffineTransform(translationX: -bounds.width * 0.5, y: -bounds.height * 0.5))
            .concatenating(view.transform)
            .concatenating(CGAffineTransform(translationX: bounds.width * 0.5, y: bounds.height * 0.5))
            .concatenating(CGAffineTransform(translationX: center.x - bounds.width * 0.5, y: center.y - bounds.height * 0.5))
            .concatenating(transform)

        context.ctm = transform

        if view.masksToBounds {
            context.addRect(bounds)
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
