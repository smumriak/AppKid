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
import TinyFoundation

// apple failed a little bit :) rdar://problem/14497260
// starting from swift 5.3 this constant is not accessible via importing Foundation and/or CoreFoundation
public let kCFStringEncodingASCII: UInt32 = 0x0600

internal var isVolcanoRenderingEnabled = false
internal var isRenderingAsync = false

public extension RunLoop.Mode {
    static let tracking: RunLoop.Mode = RunLoop.Mode("kAppKidTrackingRunLoopMode")
    static let modal: RunLoop.Mode = RunLoop.Mode("kAppKidModalRunLoopMode")
}

public protocol ApplicationDelegate: NSObjectProtocol, PublicInitializable {
    func application(_ application: Application, willFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool
    func applicationShouldTerminateAfterLastWindowClosed(_ application: Application) -> Bool
    func applicationShouldTerminate(_ application: Application) -> Application.TerminateReply
    func applicationWillTerminate(_ application: Application)
}

public extension ApplicationDelegate {
    func application(_ application: Application, willFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]? = nil) -> Bool { true }
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]? = nil) -> Bool { true }
    func applicationShouldTerminateAfterLastWindowClosed(_ application: Application) -> Bool {
        #if os(Linux) || os(Windows)
            return true
        #else
            return false
        #endif
    }

    func applicationShouldTerminate(_ application: Application) -> Application.TerminateReply { .now }
    func applicationWillTerminate(_ application: Application) {}
}

open class Application: Responder {
    internal static var _shared: Application?
    public static var shared: Application {
        if _shared == nil {
            _shared = Application()
        }

        return _shared!
    }

    open unowned(unsafe) var delegate: ApplicationDelegate?

    internal var displayServer: X11DisplayServer
    
    open fileprivate(set) var isRunning = false
    
    open var windows: [Window] { Array(windowsByNumber.values) }
    internal var windowsByNumber: [Int: Window] = [:]
    internal var renderScheduler: RenderScheduler? = nil

    internal var softwareRenderers: [Int: SoftwareRenderer] = [:]
    
    internal var eventQueue = [Event]()
    open fileprivate(set) var currentEvent: Event?
    
    internal fileprivate(set) var startTime = CFAbsoluteTimeGetCurrent()
    
    internal var lastClickTimestamp: TimeInterval = .zero
    internal var clickCount: Int = .zero

    internal var stopRequested = false

    internal lazy var softwareRenderTimer: Timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned self] _ in
        windowsByNumber.values
            .lazy
            .filter {
                $0.nativeWindow.syncRequested == false && $0.isMapped == true
            }
            .map {
                ($0, self.softwareRenderers[$0.windowNumber])
            }
            .forEach {
                $0.1?.render(window: $0.0)
            }

        self.displayServer.flush()
    }

    // internal lazy var volcanoRenderTimerAsync = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned self] _ in
    //     Task(priority: .userInitiated) { @MainActor in
    //         let renderers = windowsByNumber.values
    //             .lazy
    //             .filter {
    //                 $0.nativeWindow.syncRequested == false && $0.isMapped == true
    //             }
    //             .compactMap {
    //                 self.volcanoRenderers[$0.windowNumber]
    //             }

    //         if renderers.isEmpty {
    //             return
    //         }
            
    //         do {
    //             try await withThrowingTaskGroup(of: Void.self) { @MainActor taskGroup in
    //                 renderers.forEach { renderer in
    //                     taskGroup.addTask {
    //                         try await renderer.asyncRender()
    //                     }
    //                 }

    //                 while let _ = try await taskGroup.next() {}
    //             }
    //         } catch {
    //             fatalError("Failed to render with error: \(error)")
    //         }
    //     }
    // }

    // MARK: - Initialization

    deinit {
        displayServer.deactivate()
    }
    
    internal override init() {
        displayServer = X11DisplayServer(applicationName: "AppKid")

        do {
            try VolcanoRenderStack.setupGlobalStack()
            let renderStack: VolcanoRenderStack = VolcanoRenderStack.global
            CABackingStoreContext.setupGlobalContext(device: renderStack.device, accessQueues: [renderStack.queues.graphics, renderStack.queues.transfer])
            isVolcanoRenderingEnabled = true
            renderScheduler = try RenderScheduler(renderStack: renderStack, runLoop: CFRunLoopGetCurrent(), async: false)
        } catch {
            debugPrint("Could not start vulkan rendering. Falling back to software rendering. Error: \(error)")
        }

        displayServer.activate()

        super.init()
    }
    
    open func window(number windowNumber: Int) -> Window? {
        return windowsByNumber[windowNumber]
    }
    
    open fileprivate(set) var mainWindow: Window? = nil
    open fileprivate(set) var keyWindow: Window? = nil

    // MARK: - Run Loop

    open func stop(_ sender: Any?) {
        stopRequested = true
    }

    // MARK: - Termination
    
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

            if isVolcanoRenderingEnabled {
                let renderStack: VolcanoRenderStack = VolcanoRenderStack.global
                do {
                    try renderStack.cleanup()
                } catch {
                    fatalError("Got vulkan error while cleaning up the render stack: \(error)")
                }
            }

            exit(0)
        }
    }
    
    open func run() {
        if delegate == nil {
            fatalError("Who've forgot to specify app delegate? You've forgot to specify app delegate.")
        }
        
        isRunning = true
        startTime = CFAbsoluteTimeGetCurrent()

        let cfRunLoop = CFRunLoopGetCurrent()
        
        CFRunLoopAddCommonMode(cfRunLoop, RunLoop.Mode.tracking.cfRunLoopMode)
        CFRunLoopAddCommonMode(cfRunLoop, RunLoop.Mode.modal.cfRunLoopMode)

        if isVolcanoRenderingEnabled == false {
            RunLoop.current.add(softwareRenderTimer, forMode: .common)
        }

        let _ = delegate?.application(self, willFinishLaunchingWithOptions: nil)
        let _ = delegate?.application(self, didFinishLaunchingWithOptions: nil)

        while isRunning {
            guard let event = nextEvent(matching: .any, until: .distantFuture, in: .default, dequeue: true) else {
                break
            }

            currentEvent = event
            defer {
                currentEvent = nil
            }

            if event.type == .appKidDefined && event.subType == .terminate {
                break
            }

            send(event: event)

            if stopRequested {
                stopRequested = false
                break
            }
        }

        if isVolcanoRenderingEnabled == false {
            softwareRenderTimer.invalidate()
        }
    }

    // MARK: - Events

    open func post(event: Event, atStart: Bool) {
        eventQueue.insert(event, at: atStart ? 0 : eventQueue.count)
    }
    
    open func send(event: Event) {
        event.window?.send(event: event)
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

            if date.timeIntervalSinceReferenceDate <= Date().timeIntervalSinceReferenceDate {
                return nil
            }

            // smumriak: code performs one shot of runloop go give timers, dispatch queues and other things to process their events
            let result = RunLoop.current.run(mode: mode, before: Date())
            if result == false {
                return nil
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
                let result = RunLoop.current.run(mode: mode, before: date)
                if result == false {
                    return nil
                }
            }
        }
    }

    open func discardEvent(matching mask: Event.EventTypeMask, before event: Event) {
        guard let index = eventQueue.firstIndex(where: { $0.timestamp >= event.timestamp }) else { return }

        eventQueue.removeSubrange(0..<index)
    }

    // MARK: - Windows

    @_spi(AppKid) public func add(window: Window) {
        if isVolcanoRenderingEnabled {
            do {
                try renderScheduler?.createRenderer(for: window)
            } catch {
                fatalError("Failed to create window renderer with error: \(error)")
            }
        } else {
            let renderer = window.createRenderer()

            softwareRenderers[window.windowNumber] = renderer
        }
    }

    @_spi(AppKid) public func remove(window: Window) {
        // TODO: smumriak: order matters. renderer should always be destroyed before window is destroyed because renderer has strong reference to graphics context. this should change i.e. graphics context for particular window should be private to it's renderer
        let windowNumber = window.windowNumber

        if isVolcanoRenderingEnabled {
            do {
                try renderScheduler?.removeRenderer(for: window)
            } catch {
                fatalError("Failed to remove renderer for window \(window). Error: \(error)")
            }
        } else {
            softwareRenderers.removeValue(forKey: windowNumber)
        }
        windowsByNumber.removeValue(forKey: windowNumber)

        if windows.isEmpty && isRunning && delegate?.applicationShouldTerminateAfterLastWindowClosed(self) == true {
            // TODO: smumriak:Change to notification handling from window instead of directly doing that on remove. Also give one runloop spin for that thing
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
    // MARK: - Notifications

    static let willTerminateNotification = Notification.Name(rawValue: "willTerminateNotification")
}

public extension ApplicationDelegate {
    static func main() {
        // smumriak:This is the reason why RunLoop is used and not dispatchMain()
        // DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        //     debugPrint("ON main queue async")
        //     debugPrint("Main thread: \(Thread.mainThread)")
        //     debugPrint("Current thread: \(Thread.current)")
        // }

        // debugPrint("Before dispatchMain()")
        // debugPrint("Main thread: \(Thread.mainThread)")
        // debugPrint("Current thread: \(Thread.current)")

        // dispatchMain()

        let appDelegate = Self()
        let application = Application.shared
        application.delegate = appDelegate

        application.run()
    }
}
