//
//  Window.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import CoreFoundation
import CXlib
import CairoGraphics

// smumriak: Start from 1
internal var globalWindowCounter: Int = 1

#if os(macOS)
    import struct CairoGraphics.CGAffineTransform
#endif

public extension Notification.Name {
    static let windowDidExpose = Notification.Name(rawValue: "windowDidExpose")
    static let windowDidResize = Notification.Name(rawValue: "windowDidResize")

    static let windowDidReceiveSyncRequest = Notification.Name(rawValue: "windowDidReceiveSyncRequest") // XSync requests
}

public protocol WindowDelegate: AnyObject {
    func windowShouldClose(_ sender: Window) -> Bool
}

extension WindowDelegate {
    func windowShouldClose(_ sender: Window) -> Bool { true }
}

open class Window: View {
    public weak var delegate: WindowDelegate? = nil
    internal private(set) var windowKeepAlive: Window?
    
    public internal(set) var windowNumber: Int = 0
    @_spi(AppKid) public var nativeWindow: X11NativeWindow

    public var title: String {
        get {
            return nativeWindow.title
        }
        set {
            nativeWindow.title = newValue
        }
    }
    
    internal var _graphicsContext: X11RenderContext?

    override var transformToWindow: CGAffineTransform {
        return .identity
    }

    override var transformFromWindow: CGAffineTransform {
        return .identity
    }

    fileprivate weak var leftMouseDownView: View? = nil
    fileprivate weak var rightMouseDownView: View? = nil
    fileprivate weak var otherMouseDownView: View? = nil

    open internal(set) var firstResponder: Responder? = nil
    
    open override var window: Window? {
        get { return self }
        set {}
    }
    
    open override var transform: CGAffineTransform {
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

    open var ignoresMouseEvents: Bool {
        get {
            return nativeWindow.ignoresMouseEvents
        }
        set {
            nativeWindow.ignoresMouseEvents = newValue
        }
    }

    open override var masksToBounds: Bool {
        get { return true }
        set {}
    }

    // MARK: - Initialization

    deinit {
        let application = Application.shared

        // try? application.renderScheduler?.removeRenderer(for: self)
        application.displayServer.nativeIdentifierToWindowNumber.removeValue(forKey: nativeWindow.windowIdentifier)
    }

    internal init(nativeWindow: X11NativeWindow) {
        let application = Application.shared

        self.nativeWindow = nativeWindow
        if !isVolcanoRenderingEnabled {
            _graphicsContext = X11RenderContext(nativeWindow: nativeWindow)
            _graphicsContext?.shouldAntialias = true
        }

        var frame = nativeWindow.currentRect
        frame.size.width /= nativeWindow.displayScale
        frame.size.height /= nativeWindow.displayScale

        repeat {
            windowNumber = globalWindowCounter
            globalWindowCounter += 1
        } while application.windowsByNumber[windowNumber] != nil

        super.init(frame: frame)

        application.windowsByNumber[windowNumber] = self
        
        transformsAreValid = true

        contentScaleFactor = nativeWindow.displayScale

        application.add(window: self)
    }

    public convenience required init(contentRect: CGRect) {
        let application = Application.shared

        let displayServer = application.displayServer

        let nativeWindow = displayServer.createNativeWindow(contentRect: contentRect, title: "Window")

        // nativeWindow.transitionToFullScreen()
        // nativeWindow.setFloatsOnTop()

        self.init(nativeWindow: nativeWindow)

        displayServer.nativeIdentifierToWindowNumber[nativeWindow.windowIdentifier] = windowNumber
    }

    // MARK: - Rendering

    internal var isMapped: Bool = false

    internal func updateSurface() {
        if !isVolcanoRenderingEnabled {
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
        if isVolcanoRenderingEnabled {
            fatalError("Vulkan renderer is enabled")
        }
        return SoftwareRenderer(context: _graphicsContext!)
    }

    // MARK: - Events

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

    // MARK: - Responder

    override func responderWindow() -> Window? {
        return self
    }

    open override var nextResponder: Responder? {
        return Application.shared
    }

    // MARK: - Main Content

    fileprivate var shouldPerformRootViewControllerSetup: Bool = true

    open var rootViewController: ViewController? {
        willSet {
            if let rootViewController = rootViewController {
                rootViewController.beginAppearanceTransition(isAppearing: false, animated: false)

                rootViewController.view.removeFromSuperview()

                rootViewController.endAppearanceTransition()
            }
        }
        didSet {
            subviews.forEach { $0.removeFromSuperview() }

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

            addSubview(rootViewController.view)

            rootViewController.endAppearanceTransition()
        }
    }

    open func performClose(_ sender: Any?) {
        if delegate?.windowShouldClose(self) ?? true {
            close()
        }
    }

    open func close() {
        let application = Application.shared

        application.remove(window: self)

        // try? application.renderScheduler?.removeRenderer(for: self)
        application.windowsByNumber.removeValue(forKey: windowNumber)

        // smumriak:TODO:Send destroy request to windowing system asynchronously
    }

    internal func beforeFrameRender() {
        // smumriak:TODO: Investigate why this floods the X11 events queue
        // nativeWindow.window.sendSyncCounterForRenderingStart()
    }

    internal func afterFrameRender() {
        nativeWindow.window.sendSyncCounterIfNeeded()
    }

    internal func cancelTrackingMouse(for view: View) {
        if leftMouseDownView === view {
            leftMouseDownView = nil
        }
    }
}

public extension Window {
    static func == (lhs: Window, rhs: Window) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs) || lhs.nativeWindow == rhs.nativeWindow
    }
}

fileprivate extension Window {
    // MARK: - Send Mouse Event

    func sendMouseEvent(_ event: Event) {
        switch event.type {
            case .leftMouseDown:
                leftMouseDownView = hitTest(event.locationInWindow) ?? self
                leftMouseDownView?.mouseDown(with: event)

            case .leftMouseDragged:
                leftMouseDownView?.mouseDragged(with: event)

            case .leftMouseUp:
                leftMouseDownView?.mouseUp(with: event)
                leftMouseDownView = nil

            case .rightMouseDown:
                rightMouseDownView = hitTest(event.locationInWindow) ?? self
                rightMouseDownView?.rightMouseDown(with: event)

            case .rightMouseDragged:
                rightMouseDownView?.rightMouseDragged(with: event)

            case .rightMouseUp:
                rightMouseDownView?.rightMouseUp(with: event)
                rightMouseDownView = nil

            case .otherMouseDown:
                otherMouseDownView = hitTest(event.locationInWindow) ?? self
                otherMouseDownView?.otherMouseDown(with: event)

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

    // MARK: - Send Keyboard Event

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

    // MARK: - Handle AppKid Event

    func handleAppKidEvent(_ event: Event) {
        let notificationCenter = NotificationCenter.default

        switch event.subType {
            case .windowDeleteRequest:
                performClose(self)

            case .windowMapped:
                isMapped = true

            case .windowUnmapped:
                isMapped = false

            case .windowExposed:
                if isMapped && shouldPerformRootViewControllerSetup {
                    setupRootViewController()

                    shouldPerformRootViewControllerSetup = false
                }

                if isMapped {
                    updateSurface()
                }

                notificationCenter.post(name: .windowDidExpose, object: self)

            case .configurationChanged:
                let newSize = CGSize(width: event.deltaX, height: event.deltaY)
                let sizeChanged = (newSize != bounds.size)

                if sizeChanged {
                    if isMapped {
                        updateSurface()
                    }
                }

                if sizeChanged {
                    notificationCenter.post(name: .windowDidResize, object: self)
                }

                Application.shared.renderScheduler?.windowWasResized(self)

            case .windowSyncRequest:
                nativeWindow.window.syncRequested(with: event.syncCounterValue)
            
                notificationCenter.post(name: .windowDidReceiveSyncRequest, object: self)

            default:
                break
        }
    }
}
