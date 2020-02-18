//
//  Window.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
//

import Foundation
import CX11.Xlib
import CX11.X
import CairoGraphics

open class Window: View {
    internal var nativeWindow: X11NativeWindow
    
    internal var _windowNumber: Int { Int(nativeWindow.windowID) }
    internal var _graphicsContext: X11RenderContext
    
    override public var window: Window? {
        get { return self }
        set {}
    }
    
    override public var transform: CairoGraphics.CGAffineTransform {
        get { return .identity }
        set {}
    }
    
    internal init(nativeWindow: X11NativeWindow) {
        self.nativeWindow = nativeWindow
        _graphicsContext = X11RenderContext(nativeWindow: nativeWindow)
        _graphicsContext.shouldAntialias = true
        
        super.init(with: nativeWindow.currentRect)
        
        transformsAreValid = true
    }

    convenience init(contentRect: CGRect) {
        let display = Application.shared.display
        let screen = Application.shared.screen
        let rootWindow = Application.shared.rootWindow

        let nativeWindow = X11NativeWindow(display: display, screen: screen, rect: contentRect, parent: rootWindow.nativeWindow.windowID)

        self.init(nativeWindow: nativeWindow)
    }
    
    public func post(event: Event, atStart: Bool) {
        Application.shared.post(event: event, atStart: atStart)
    }
    
    public func send(event: Event) {
        switch event.type {
        case .appKidDefined:
            switch event.subType {
            case .windowExposed, .windowResized:
                _graphicsContext.updateSurface()
                let currentRect = nativeWindow.currentRect
                bounds.size = currentRect.size
                center = CGPoint(x: bounds.midX, y:bounds.midY)
                render()
                
            default:
                break
            }
            
        case .leftMouseDown, .leftMouseDragged:
            break
            
        case .rightMouseDown, .rightMouseDragged:
            break
            
        case .leftMouseUp:
            if let view = hitTest(event.locationInWindow) {
                view.backgroundColor = view.backgroundColor.negative
                render()
            }

        default:
            break
        }
    }
    
    override func invalidateTransforms() {}
    
    override func rebuildTransformsIfNeeded() {
        _transformToWindow = .identity
        _transformFromWindow = .identity
    }

    public func render() {
        CairoGraphics.CGContext.push(_graphicsContext)
        _graphicsContext.saveState()

        render(view: self, in: _graphicsContext)

        _graphicsContext.restoreState()
        CairoGraphics.CGContext.pop()

        XSync(nativeWindow.display, 0)
    }

    fileprivate func render(view: View, in context: CairoGraphics.CGContext) {
        context.translateBy(x: view.center.x, y: view.center.y)
        context.concatenate(view.transform)

        context.translateBy(x: -view.bounds.width * 0.5, y: -view.bounds.height * 0.5)
        view.render(in: context)

        for subview in view.subviews {
            render(view: subview, in: context)
        }
        
        context.translateBy(x: view.bounds.width * 0.5, y: view.bounds.height * 0.5)

        context.concatenate(view.transform.inverted())
        context.translateBy(x: -view.center.x, y: -view.center.y)
    }
}

extension Window {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return lhs === rhs || lhs.nativeWindow == rhs.nativeWindow
    }
}
