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
    internal var _display: UnsafeMutablePointer<CX11.Display>
    internal var _screen: UnsafeMutablePointer<CX11.Screen>
    internal var _x11Window: CX11.Window
    internal var _windowNumber: Int { Int(_x11Window) }
    internal var _graphicsContext: CairoGraphics.CGContext
    
    override public var window: Window? {
        get { return self }
        set {}
    }
    
    override public var transform: CairoGraphics.CGAffineTransform {
        get { return .identity }
        set {}
    }
    
    deinit {
        XDestroyWindow(_display, _x11Window)
    }
    
    internal init(x11Window: CX11.Window, display: UnsafeMutablePointer<CX11.Display>, screen: UnsafeMutablePointer<CX11.Screen>, contentRect: CGRect = .zero) {
        _x11Window = x11Window
        _display = display
        _screen = screen
        
        _graphicsContext = CairoGraphics.CGContext(display: display, window: x11Window)
        
        super.init(with: contentRect)
        
        transformsAreValid = true
    }
    
    convenience init(contentRect: CGRect) {
        let display = Application.shared.display
        let screen = Application.shared.screen
        let rootWindow = Application.shared.rootWindow
        
        let x11Window = XCreateSimpleWindow(display, rootWindow._x11Window, Int32(contentRect.minX), Int32(contentRect.minY), UInt32(contentRect.width), UInt32(contentRect.height), 1, screen.pointee.black_pixel, screen.pointee.white_pixel)
        
        XSelectInput(display, x11Window, Event.EventType.x11EventMask())
        XMapWindow(display, x11Window)
        XSetWMProtocols(display, x11Window, &Application.shared.wmDeleteWindowAtom, 1);
        XFlush(display)
        
        self.init(x11Window: x11Window, display: display, screen: screen, contentRect: contentRect)
    }
    
    public func post(event: Event, atStart: Bool) {
        Application.shared.post(event: event, atStart: atStart)
    }
    
    public func send(event: Event) {
        switch event.type {
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
    }
}

extension Window {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return lhs === rhs || lhs._x11Window == rhs._x11Window
    }
}
