//
//  Application.swift
//  AppKid
//
//  Created by Serhii Mumriak on 31.01.2020.
//

import Foundation
import CoreFoundation
import CXlib
import CairoGraphics
@_spi(AppKid) import ContentAnimation

// apple failed a little bit :) rdar://problem/14497260
// starting from swift 5.3 this constant is not accessible via importing Foundation and/or CoreFoundation
public let kCFStringEncodingASCII: UInt32 = 0x0600

internal var isVolcanoRenderingEnabled = false

public extension RunLoop.Mode {
    static let tracking: RunLoop.Mode = RunLoop.Mode("kAppKidTrackingRunLoopMode")
}

public protocol ApplicationDelegate: AnyObject {
    func application(_ application: Application, willFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool
    func applicationShouldTerminateAfterLastWindowClosed(_ application: Application) -> Bool
    func applicationShouldTerminate(_ application: Application) -> Application.TerminateReply
    func applicationWillTerminate(_ application: Application)
}

public extension ApplicationDelegate {
    func application(_ application: Application, willFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]? = nil) -> Bool { true }
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]? = nil) -> Bool { true }
    func applicationShouldTerminateAfterLastWindowClosed(_ application: Application) -> Bool { false }
    func applicationShouldTerminate(_ application: Application) -> Application.TerminateReply { .now }
    func applicationWillTerminate(_ application: Application) {}
}

open class Application: Responder {
    public static let shared = Application()
    open unowned(unsafe) var delegate: ApplicationDelegate?

    internal var displayServer: X11DisplayServer
    
    open fileprivate(set) var isRunning = false
    
    open fileprivate(set) var windows: [Window] = []
    internal var softwareRenderers: [SoftwareRenderer] = []
    internal var volcanoRenderers: [VolcanoSwapchainRenderer] = []
    
    internal var eventQueue = [Event]()
    open fileprivate(set) var currentEvent: Event?
    
    internal fileprivate(set) var startTime = CFAbsoluteTimeGetCurrent()
    
    internal var runLoopSource: CFRunLoopSource? = nil
    
    internal var lastClickTimestamp: TimeInterval = .zero
    internal var clickCount: Int = .zero

    internal lazy var softwareRenderTimer: Timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned self] _ in
        zip(self.windows, self.softwareRenderers).forEach { window, renderer in
            if window.nativeWindow.syncRequested { return }
            
            if window.isMapped {
                renderer.render(window: window)
            }
        }

        self.displayServer.flush()
    }

    internal lazy var volcanoRenderTimer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned self] _ in
        do {
            let renderStack: VolcanoRenderStack = VolcanoRenderStack.global

            let renderers = Array(
                zip(self.windows, self.volcanoRenderers)
                    .lazy
                    .filter { $0.0.nativeWindow.syncRequested == false && $0.0.isMapped == true }
                    .map { $0.1 }
            )

            if renderers.isEmpty {
                return
            }

            let fences = renderers.map { $0.layerRenderer.fence }

            try renderStack.device.reset(fences: fences)

            try renderers.forEach { renderer in
                    try renderer.render()
                }

            try renderStack.device.wait(forFences: fences, waitForAll: true)

            try renderers.forEach { renderer in
                try renderer.layerRenderer.endFrame()
            }
            
        } catch {
            fatalError("Failed to render with error: \(error)")
        }
    }

    // MARK: Initialization

    deinit {
        displayServer.deactivate()
    }
    
    internal override init() {
        displayServer = X11DisplayServer(applicationName: "SwiftyFan")

        do {
            try VolcanoRenderStack.setupGlobalStack()
            let renderStack: VolcanoRenderStack = VolcanoRenderStack.global
            CABackingStoreContext.setupGlobalContext(device: renderStack.device, accessQueues: [renderStack.queues.graphics, renderStack.queues.transfer])
            isVolcanoRenderingEnabled = true
        } catch {
            debugPrint("Could not start vulkan rendering. Falling back to software rendering")
        }

        displayServer.activate()

        super.init()
    }
    
    open func window(number windowNumber: Int) -> Window? {
        return windows.indices.contains(windowNumber) ? windows[windowNumber] : nil
    }
    
    open fileprivate(set) var mainWindow: Window? = nil
    open fileprivate(set) var keyWindow: Window? = nil

    // MARK: Run Loop

    open func stop() {
        CFRunLoopStop(RunLoop.current.getCFRunLoop())
    }

    // MARK: Termination
    
    open func terminate() {
        let terminate: TerminateReply = delegate?.applicationShouldTerminate(self) ?? .now

        if terminate == .now {
            reply(toApplicationShouldTerminate: true)
        }
    }

    open func reply(toApplicationShouldTerminate shouldTerminate: Bool) {
        if isRunning && shouldTerminate {
            delegate?.applicationWillTerminate(self)
            NotificationCenter.default.post(name: Application.willTerminateNotification, object: self)

            isRunning = false

            let windows = self.windows
            windows.forEach { $0.close() }

            exit(0)
        }
    }
    
    open func run() {
        if delegate == nil {
            fatalError("Who've forgot to specify app delegate? You've forgot to specify app delegate.")
        }
        
        isRunning = true
        startTime = CFAbsoluteTimeGetCurrent()

        #if os(Linux)
            let trackingCFRunLoopMode = CFStringCreateWithCString(nil, RunLoop.Mode.tracking.rawValue, CFStringEncoding(kCFStringEncodingASCII))
        #else
            let trackingCFRunLoopMode = CFRunLoopMode(rawValue: RunLoop.Mode.tracking.rawValue as CFString)
        #endif
        CFRunLoopAddCommonMode(RunLoop.current.getCFRunLoop(), trackingCFRunLoopMode)

        if isVolcanoRenderingEnabled {
            RunLoop.current.add(volcanoRenderTimer, forMode: .common)
        } else {
            RunLoop.current.add(softwareRenderTimer, forMode: .common)
        }

        let _ = delegate?.application(self, willFinishLaunchingWithOptions: nil)
        let _ = delegate?.application(self, didFinishLaunchingWithOptions: nil)

        while isRunning {
            guard let event = nextEvent(matching: .any, until: Date.distantFuture, in: .default, dequeue: true) else {
                break
            }

            if event.type == .appKidDefined && event.subType == .terminate {
                break
            }

            send(event: event)
        }

        if isVolcanoRenderingEnabled {
            volcanoRenderTimer.invalidate()
        } else {
            softwareRenderTimer.invalidate()
        }
    }

    // MARK: Events

    open func post(event: Event, atStart: Bool) {
        eventQueue.insert(event, at: atStart ? 0 : eventQueue.count)
    }
    
    open func send(event: Event) {
        currentEvent = event
        event.window?.send(event: event)
        currentEvent = nil
    }

    internal func indexOfEvent(matching mask: Event.EventTypeMask, serviceDisplayServerEventQueue: Bool = true) -> Array<Event>.Index? {
        if serviceDisplayServerEventQueue {
            displayServer.serviceEventsQueue()
        }

        return eventQueue.firstIndex { mask.contains($0.type.mask) }
    }
    
    open func nextEvent(matching mask: Event.EventTypeMask, until date: Date, in mode: RunLoop.Mode, dequeue: Bool) -> Event? {
        while true {
            guard isRunning else {
                return Event(withAppKidEventSubType: .terminate, windowNumber: NSNotFound)
            }

            // palkovnik: code performs one shot of runloop go give timears, dispatch queues and other things to process their events
            let result = CFRunLoopRunInMode(mode.cfRunLoopMode, 0, true)
            switch result {
                case .finished: return nil
                case .stopped: return nil
                case .timedOut: break
                case .handledSource: break
                default: break
            }
            
            if let index = indexOfEvent(matching: mask) {
                let event = eventQueue[index]

                let eventIgnored = event.type == .appKidDefined && event.subType == .ignoredDisplayServerEvent

                if dequeue || eventIgnored {
                    eventQueue.remove(at: index)
                }

                if eventIgnored {
                    continue
                }

                return event
            } else {
                let seconds = date.timeIntervalSinceReferenceDate - CFAbsoluteTimeGetCurrent()

                let result = CFRunLoopRunInMode(mode.cfRunLoopMode, seconds, true)

                switch result {
                    case .finished: return nil
                    case .stopped: return nil
                    case .timedOut: break
                    case .handledSource: break
                    default: break
                }
            }
        }
    }

    open func discardEvent(matching mask: Event.EventTypeMask, before event: Event) {
        guard let index = eventQueue.firstIndex(where: { $0.timestamp >= event.timestamp }) else { return }

        eventQueue.removeSubrange(0..<index)
    }

    // MARK: Windows

    open func add(window: Window) {
        windows.append(window)
        if isVolcanoRenderingEnabled {
            do {
                let renderer = try VolcanoSwapchainRenderer(window: window, renderStack: VolcanoRenderStack.global)
                
                volcanoRenderers.append(renderer)
            } catch {
                fatalError("Failed to create window renderer with error: \(error)")
            }
        } else {
            softwareRenderers.append(window.createRenderer())
        }
    }

    open func remove(window: Window) {
        if let index = windows.firstIndex(of: window) {
            remove(windowNumer: index)
        }
    }

    open func remove(windowNumer index: Array<Window>.Index) {
        // TODO: palkovnik: order matters. renderer should always be destroyed before window is destroyed because renderer has strong reference to graphics context. this should change i.e. graphics context for particular window should be private to it's renderer
        if isVolcanoRenderingEnabled {
            // let renderer = volcanoRenderers.remove(at: index)
            // try? renderer.device.waitForIdle()
            volcanoRenderers.remove(at: index)
        } else {
            softwareRenderers.remove(at: index)
        }
        windows.remove(at: index)

        if windows.isEmpty && isRunning && delegate?.applicationShouldTerminateAfterLastWindowClosed(self) == true {
            // TODO: palkovnik:Change to notification handling from window instead of directly doing that on remove. Also give one runloop spin for that thing
            terminate()
        }
    }
}

public extension Application {
    struct LaunchOptionsKey: Hashable, Equatable, RawRepresentable {
        public typealias RawValue = String
        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

public extension Application {
    enum TerminateReply: UInt {
        case cancel = 0
        case now = 1
        case later = 2
    }
}

public extension Application {
    // MARK: Notifications

    static let willTerminateNotification = Notification.Name(rawValue: "willTerminateNotification")
}
