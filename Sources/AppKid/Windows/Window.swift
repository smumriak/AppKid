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

    fileprivate var leftMouseDownView: View? = nil
    fileprivate var rightMouseDownView: View? = nil
    fileprivate var otherMouseDownView: View? = nil
    
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

        var frame = nativeWindow.currentRect
        frame.size.width /= nativeWindow.displayScale
        frame.size.height /= nativeWindow.displayScale

        super.init(with: frame)
        
        transformsAreValid = true
    }

    public convenience required init(contentRect: CGRect) {
        let display = Application.shared.display
        let screen = Application.shared.screen
        let rootWindow = Application.shared.rootWindow
        let displayScale = Application.shared.displayScale

        var scaledContentRect = contentRect
        scaledContentRect.size.width *= displayScale
        scaledContentRect.size.height *= displayScale

        let nativeWindow = X11NativeWindow(display: display, screen: screen, rect: scaledContentRect, parent: rootWindow.windowID)
        nativeWindow.displayScale = displayScale

        self.init(nativeWindow: nativeWindow)
    }
    
    public func post(event: Event, atStart: Bool) {
        Application.shared.post(event: event, atStart: atStart)
    }
    
    public func send(event: Event) {
        if Event.EventType.mouseEventTypes.contains(event.type) {
            sendMouseEvent(event)
        } else {
            switch event.type {
            case .appKidDefined:
                switch event.subType {
                case .windowExposed, .windowResized:
                    _graphicsContext.updateSurface()
                    var currentRect = nativeWindow.currentRect
                    currentRect.size.width /= nativeWindow.displayScale
                    currentRect.size.height /= nativeWindow.displayScale
                    bounds.size = currentRect.size
                    center = CGPoint(x: bounds.midX, y:bounds.midY)

                default:
                    break
                }

            default:
                break
            }
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
        _graphicsContext.scaleBy(x: nativeWindow.displayScale, y: nativeWindow.displayScale)

        render(view: self, in: _graphicsContext)

        _graphicsContext.restoreState()
        CairoGraphics.CGContext.pop()

        nativeWindow.sync()
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

fileprivate extension Window {
    func sendMouseEvent(_ event: Event) {
        switch event.type {
        case .leftMouseDown:
            leftMouseDownView = hitTest(event.locationInWindow) ?? self
            leftMouseDownView?.mouseDown(with: event)

            repeat {
                let nextEvent = Application.shared.nextEvent(matching: [.leftMouseDragged, .leftMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true)

                Application.shared.send(event: nextEvent)

                if nextEvent.type == .leftMouseUp {
                    Application.shared.discardEvent(matching: .any, before: nextEvent)
                    break
                }
            } while true

        case .leftMouseDragged:
            leftMouseDownView?.mouseDragged(with: event)

        case .leftMouseUp:
            leftMouseDownView?.mouseUp(with: event)
            leftMouseDownView = nil

        case .rightMouseDown:
            rightMouseDownView = hitTest(event.locationInWindow) ?? self
            rightMouseDownView?.rightMouseDown(with: event)

            repeat {
                let nextEvent = Application.shared.nextEvent(matching: [.rightMouseDragged, .rightMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true)

                Application.shared.send(event: nextEvent)

                if nextEvent.type == .rightMouseUp {
                    Application.shared.discardEvent(matching: .any, before: nextEvent)
                    break
                }
            } while true

        case .rightMouseDragged:
            rightMouseDownView?.rightMouseDragged(with: event)

        case .rightMouseUp:
            rightMouseDownView?.rightMouseUp(with: event)
            rightMouseDownView = nil

        case .otherMouseDown:
            otherMouseDownView = hitTest(event.locationInWindow) ?? self
            otherMouseDownView?.otherMouseDown(with: event)

            repeat {
                let nextEvent = Application.shared.nextEvent(matching: [.otherMouseDragged, .otherMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true)

                Application.shared.send(event: nextEvent)

                if nextEvent.type == .otherMouseUp {
                    Application.shared.discardEvent(matching: .any, before: nextEvent)
                    break
                }
            } while true

        case .otherMouseDragged:
            otherMouseDownView?.otherMouseDragged(with: event)

        case .otherMouseUp:
            otherMouseDownView?.otherMouseUp(with: event)
            otherMouseDownView = nil

        default:
            guard let handler = Responder.mouseEventTypeToHandler[event.type] else { return }
            let view = hitTest(event.locationInWindow) ?? self
            handler(view)(event)
        }
    }
}
