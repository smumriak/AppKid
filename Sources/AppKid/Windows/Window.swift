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
                center = CGPoint(x: currentRect.midX, y:currentRect.midY)
                draw(bounds)
                
            default:
                break
            }
            
        case .leftMouseDown, .leftMouseDragged:
            _graphicsContext.saveState()
            _graphicsContext.setFillColor(.black)
            _graphicsContext.fill(CGRect(origin: event.locationInWindow, size: CGSize(width: 20.0, height: 20.0)))
            _graphicsContext.restoreState()
            
        case .rightMouseDown, .rightMouseDragged:
            _graphicsContext.saveState()
            _graphicsContext.setFillColor(.white)
            _graphicsContext.fill(CGRect(origin: event.locationInWindow, size: CGSize(width: 20.0, height: 20.0)))
            _graphicsContext.restoreState()
            
        case .leftMouseUp:
            break

        default:
            break
        }
    }
    
    override func invalidateTransforms() {}
    
    override func rebuildTransformsIfNeeded() {
        _transformToWindow = .identity
        _transformFromWindow = .identity
    }
    
    public override func draw(_ rect: CGRect) {
        CairoGraphics.CGContext.push(_graphicsContext)
        _graphicsContext.saveState()
        super.draw(rect)
        
        var renderViewStack = subviews.filter {
            let transformedBounds = $0.bounds.applying($0.transform)
            return $0.convert(transformedBounds, to: self).intersects(rect)
        }
        
        repeat {
            guard let currentView = renderViewStack.first else { continue }
            renderViewStack.removeFirst()
            
            let targetRect = currentView.superview?.convert(rect, from: self) ?? rect
            
            let intersectionRect = currentView.frame.intersection(targetRect)
            
            if intersectionRect.isNull == false {
                let convertedRect = convert(intersectionRect, to: currentView)
                
                let subviewsToRender = currentView.subviews.filter {
                    let transformedBounds = $0.bounds.applying($0.transform)
                    return $0.convert(transformedBounds, to: currentView.superview ?? self).intersects(convertedRect)
                }
                
                renderViewStack.insert(contentsOf: subviewsToRender, at: 0)
                
                _graphicsContext.concatenate(currentView.transformToWindow)
                currentView.draw(currentView.bounds)
                _graphicsContext.concatenate(currentView.transformFromWindow)
            }
        } while renderViewStack.isEmpty == false
        
        _graphicsContext.restoreState()
        CairoGraphics.CGContext.pop()
        
        XSync(nativeWindow.display, 0)
    }
}

extension Window {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return lhs === rhs || lhs.nativeWindow == rhs.nativeWindow
    }
}
