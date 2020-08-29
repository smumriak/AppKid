//
//  Window.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import CXlib
import CXInput2
import CairoGraphics

extension Notification.Name {
    public static let windowDidExpose = Notification.Name(rawValue: "windowDidExpose")
    public static let windowDidResize = Notification.Name(rawValue: "windowDidResize")

    public static let windowDidReceiveSyncRequest = Notification.Name(rawValue: "windowDidReceiveSyncRequest") // XSync requests
}

public protocol WindowDelegate: class {
    func windowShouldClose(_ sender: Window) -> Bool
}

extension WindowDelegate {
    func windowShouldClose(_ sender: Window) -> Bool { true }
}

open class Window: View {
    public weak var delegate: WindowDelegate? = nil
    
    public var nativeWindow: X11NativeWindow

    public var title: String {
        get {
            return nativeWindow.title
        }
        set {
            nativeWindow.title = newValue
        }
    }
    
    internal var _graphicsContext: X11RenderContext?

    override var transformToWindow: CairoGraphics.CGAffineTransform {
        return .identity
    }

    override var transformFromWindow: CairoGraphics.CGAffineTransform {
        return .identity
    }

    fileprivate var leftMouseDownView: View? = nil
    fileprivate var rightMouseDownView: View? = nil
    fileprivate var otherMouseDownView: View? = nil

    open internal(set) var firstResponder: Responder? = nil
    
    open override var window: Window? {
        get { return self }
        set {}
    }
    
    open override var transform: CairoGraphics.CGAffineTransform {
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
        if !isVulkanRendererEnabled {
            _graphicsContext = X11RenderContext(nativeWindow: nativeWindow)
            _graphicsContext?.shouldAntialias = true
        }

        var frame = nativeWindow.currentRect
        frame.size.width /= nativeWindow.displayScale
        frame.size.height /= nativeWindow.displayScale

        super.init(with: frame)
        
        transformsAreValid = true
    }

    public convenience required init(contentRect: CGRect) {
        let displayServer = Application.shared.displayServer

        let nativeWindow = displayServer.createNativeWindow(contentRect: contentRect, title: "Window")

        self.init(nativeWindow: nativeWindow)
    }

    // MARK: Rendering

    internal var isMapped: Bool = false

    internal func updateSurface() {
        if !isVulkanRendererEnabled {
            _graphicsContext?.updateSurface()
        }
        var currentRect = nativeWindow.currentRect
        currentRect.size.width /= nativeWindow.displayScale
        currentRect.size.height /= nativeWindow.displayScale

        bounds.size = currentRect.size
        center = CGPoint(x: bounds.midX, y: bounds.midY)

        rootViewController?.view.frame = bounds
        rootViewController?.view.setNeedsLayout()
        rootViewController?.view.layoutIfNeeded()
    }

    internal func createRenderer() -> SoftwareRenderer {
        if isVulkanRendererEnabled {
            fatalError("Vulkan renderer is enabled")
        }
        return SoftwareRenderer(context: _graphicsContext!)
    }

    // MARK: Events

    open func post(event: Event, atStart: Bool) {
        Application.shared.post(event: event, atStart: atStart)
    }
    
    open func send(event: Event) {
        switch event.type {
        case _ where event.type.isAnyMouse:
            sendMouseEvent(event)

        case _ where event.type.isAnyKeyboard:
            sendKeyboardEvent(event)

        case .appKidDefined:
            handleAppKidEvent(event)

        default:
            break
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
            rootViewController.loadViewIfNeeded()
            
            rootViewController.beginAppearanceTransition(isAppearing: true, animated: false)

            rootViewController.view.frame = bounds

            add(subview: rootViewController.view)

            rootViewController.endAppearanceTransition()
        }
    }

    open func performClose(_ sender: Any?) {
        if delegate?.windowShouldClose(self) ?? true {
            close()
        }
    }

    open func close() {
        Application.shared.remove(window: self)
    }
}

extension Window {
    public static func == (lhs: Window, rhs: Window) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs) || lhs.nativeWindow == rhs.nativeWindow
    }
}

fileprivate extension Window {
    // MARK: Send Mouse Event

    func sendMouseEvent(_ event: Event) {
        let application = Application.shared

        switch event.type {
        case .leftMouseDown:
            leftMouseDownView = hitTest(event.locationInWindow) ?? self
            leftMouseDownView?.mouseDown(with: event)

            while true {
                guard let nextEvent = application.nextEvent(matching: [.leftMouseDragged, .leftMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true) else {
                    break
                }

                application.send(event: nextEvent)

                if nextEvent.type == .leftMouseUp {
                    application.discardEvent(matching: .any, before: nextEvent)
                    break
                }
            }

        case .leftMouseDragged:
            leftMouseDownView?.mouseDragged(with: event)

        case .leftMouseUp:
            leftMouseDownView?.mouseUp(with: event)
            leftMouseDownView = nil

        case .rightMouseDown:
            rightMouseDownView = hitTest(event.locationInWindow) ?? self
            rightMouseDownView?.rightMouseDown(with: event)

            while true {
                guard let nextEvent = application.nextEvent(matching: [.rightMouseDragged, .rightMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true) else {
                    break
                }

                application.send(event: nextEvent)

                if nextEvent.type == .rightMouseUp {
                    application.discardEvent(matching: .any, before: nextEvent)
                    break
                }
            }

        case .rightMouseDragged:
            rightMouseDownView?.rightMouseDragged(with: event)

        case .rightMouseUp:
            rightMouseDownView?.rightMouseUp(with: event)
            rightMouseDownView = nil

        case .otherMouseDown:
            otherMouseDownView = hitTest(event.locationInWindow) ?? self
            otherMouseDownView?.otherMouseDown(with: event)

            while true {
                guard let nextEvent = application.nextEvent(matching: [.otherMouseDragged, .otherMouseUp], until: Date.distantFuture, in: .tracking, dequeue: true) else {
                    break
                }

                application.send(event: nextEvent)

                if nextEvent.type == .otherMouseUp {
                    application.discardEvent(matching: .any, before: nextEvent)
                    break
                }
            }

        case .otherMouseDragged:
            otherMouseDownView?.otherMouseDragged(with: event)

        case .otherMouseUp:
            otherMouseDownView?.otherMouseUp(with: event)
            otherMouseDownView = nil

        case .scrollWheel:
            let view = hitTest(event.locationInWindow) ?? self
            view.scrollWheel(with: event)

        default:
            guard let handler = Responder.mouseEventTypeToHandler[event.type] else { return }
            let view = hitTest(event.locationInWindow) ?? self
            handler(view)(event)
        }
    }

    // MARK: Send Keyboard Event

    func sendKeyboardEvent(_ event: Event) {
        switch event.type {
        case .keyDown:
            firstResponder?.keyDown(with: event)

        case .keyUp:
            firstResponder?.keyUp(with: event)

        default:
            break
        }
    }

    // MARK: Handle AppKid Event

    func handleAppKidEvent(_ event: Event) {
        let notificationCenter = NotificationCenter.default

        switch event.subType {
        case .windowDeleteRequest:
            performClose(self)

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

            if nativeWindow.syncRequested == true && nativeWindow.rendererResized == true {
                nativeWindow.sendExtendedSyncCounterValue()
                nativeWindow.syncRequested = false
                nativeWindow.rendererResized = false
            }

            notificationCenter.post(name: .windowDidExpose, object: self)

        case .windowDidResize:
            if isMapped {
                let newSize = CGSize(width: event.deltaX, height: event.deltaY)

                if newSize != bounds.size {
                    updateSurface()
                }
            }

            let application = Application.shared

            if let index = application.windows.firstIndex(of: self) {
                if isVulkanRendererEnabled {
                    do {
                        try application.vulkanRenderers[index].render()
                    } catch {
                        fatalError("Failed to render with error: \(error)")
                    }
                } else {
                    // TODO: palkovnik: Consolidate the workflow of software and vulkan based renderers. Currently it's a little bit of a mess. At least before CARenderer is implemented
                }

                nativeWindow.rendererResized = true
            }

            notificationCenter.post(name: .windowDidResize, object: self)

        case .windowSyncRequest:
            nativeWindow.syncRequested = true
            nativeWindow.extendedSyncCounter = event.syncCounter

            notificationCenter.post(name: .windowDidReceiveSyncRequest, object: self)

        default:
            break
        }
    }
}
