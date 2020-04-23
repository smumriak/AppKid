//
//  Window.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import CX11.Xlib
import CX11.X
import CXInput2
import CairoGraphics

open class Window: View {
    internal var nativeWindow: X11NativeWindow
    
    internal var _windowNumber: Int { Int(nativeWindow.windowID) }
    internal var _graphicsContext: X11RenderContext

    override var transformToWindow: CairoGraphics.CGAffineTransform {
        return .identity
    }

    override var transformFromWindow: CairoGraphics.CGAffineTransform {
        return .identity
    }

    fileprivate var leftMouseDownView: View? = nil
    fileprivate var rightMouseDownView: View? = nil
    fileprivate var otherMouseDownView: View? = nil

    internal(set) open var firstResponder: Responder? = nil
    
    override open var window: Window? {
        get { return self }
        set {}
    }
    
    override open var transform: CairoGraphics.CGAffineTransform {
        get { return .identity }
        set {}
    }

    open var acceptsMouseMovedEvents: Bool {
        get {
            return nativeWindow.acceptsMouseMovedEvents
        }
        set {
            nativeWindow.acceptsMouseMovedEvents = newValue
        }
    }

    open override var masksToBounds: Bool {
        get { return true }
        set {}
    }

    // MARK: Initialization

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
        let displayServer = Application.shared.displayServer

        let nativeWindow = displayServer.createNativeWindow(contentRect: contentRect)

        self.init(nativeWindow: nativeWindow)
    }

    // MARK: Rendering

    internal var isMapped: Bool = false

    internal func updateSurface() {
        _graphicsContext.updateSurface()
        var currentRect = nativeWindow.currentRect
        currentRect.size.width /= nativeWindow.displayScale
        currentRect.size.height /= nativeWindow.displayScale
        bounds.size = currentRect.size
        center = CGPoint(x: bounds.midX, y:bounds.midY)

        rootViewController?.view.frame = bounds
        rootViewController?.view.setNeedsLayout()
        rootViewController?.view.layoutIfNeeded()
    }

    // MARK: Events

    open func post(event: Event, atStart: Bool) {
        Application.shared.post(event: event, atStart: atStart)
    }
    
    open func send(event: Event) {
        if Event.EventType.mouseEventTypes.contains(event.type) {
            sendMouseEvent(event)
        } else {
            switch event.type {
            case .appKidDefined:
                switch event.subType {
                case .windowMapped:
                    isMapped = true
                    shouldPerformRootViewControllerSetup = true

                case .windowExposed:
                    if isMapped && shouldPerformRootViewControllerSetup {
                        setupRootViewController()

                        shouldPerformRootViewControllerSetup = false
                    }

                    if isMapped {
                        updateSurface()
                    }

                case .windowResized:
                    if isMapped {
                        updateSurface()
                    }

                default:
                    break
                }

            default:
                break
            }
        }
    }

    override func invalidateTransforms() {}
    override func rebuildTransformsIfNeeded() {}

    // MARK: Responder

    override func responderWindow() -> Window? {
        return self
    }

    open override var nextResponder: Responder? {
        return Application.shared
    }

    // MARK: Main Content

    fileprivate var shouldPerformRootViewControllerSetup: Bool = false

    open var rootViewController: ViewController? {
        willSet {
            if let rootViewController = rootViewController {
                rootViewController.beginAppearanceTransition(isAppearing: false, animated: false)

                rootViewController.view.removeFromSuperView()

                rootViewController.endAppearanceTransition()
            }
        }
        didSet {
            subviews.forEach { $0.removeFromSuperView() }

            if isMapped {
                setupRootViewController()
            }
        }
    }

    internal func setupRootViewController() {
        if let rootViewController = rootViewController {
            rootViewController.beginAppearanceTransition(isAppearing: true, animated: false)

            rootViewController.view.frame = bounds

            add(subview: rootViewController.view)

            rootViewController.endAppearanceTransition()
        }
    }
}

extension Window {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs) || lhs.nativeWindow == rhs.nativeWindow
    }
}

fileprivate extension Window {
    func sendMouseEvent(_ event: Event) {
        let application = Application.shared

        switch event.type {
        case .leftMouseDown:
            leftMouseDownView = hitTest(event.locationInWindow) ?? self
            leftMouseDownView?.mouseDown(with: event)

            repeat {
                let nextEvent = application.nextEvent(matching: [.leftMouseDragged, .leftMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true)

                application.send(event: nextEvent)

                if nextEvent.type == .leftMouseUp {
                    application.discardEvent(matching: .any, before: nextEvent)
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
                let nextEvent = application.nextEvent(matching: [.rightMouseDragged, .rightMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true)

                application.send(event: nextEvent)

                if nextEvent.type == .rightMouseUp {
                    application.discardEvent(matching: .any, before: nextEvent)
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
                let nextEvent = application.nextEvent(matching: [.otherMouseDragged, .otherMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true)

                application.send(event: nextEvent)

                if nextEvent.type == .otherMouseUp {
                    application.discardEvent(matching: .any, before: nextEvent)
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
