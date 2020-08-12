//
//  Application.swift
//  AppKid+16505059497
//
//  Created by Serhii Mumriak on 31.01.2020.
//

import Foundation
import CoreFoundation
import CX11.Xlib
import CX11.X
import CXInput2
import CairoGraphics

// apple failed a little bit :) rdar://problem/14497260
// starting from swift 5.3 this constant is not accessible via importing Foundation and/or CoreFoundation
public let kCFStringEncodingASCII: UInt32 = 0x0600

internal let isVulkanRendererEnabled = true

public extension RunLoop.Mode {
    static let tracking: RunLoop.Mode = RunLoop.Mode("kAppKidTrackingRunLoopMode")
}

public protocol ApplicationDelegate: class {
    func application(_ application: Application, willFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey : Any]?) -> Bool
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey : Any]?) -> Bool
    func applicationShouldTerminateAfterLastWindowClosed(_ application: Application) -> Bool
}

public extension ApplicationDelegate {
    func application(_ application: Application, willFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey : Any]? = nil) -> Bool { return true }
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey : Any]? = nil) -> Bool { return true }
    func applicationShouldTerminateAfterLastWindowClosed(_ application: Application) -> Bool { return false }
}

open class Application: Responder {
    public static let shared = Application()
    unowned(unsafe) open var delegate: ApplicationDelegate?

    internal var displayServer: DisplayServer
    
    open fileprivate(set) var isRunning = false
    open fileprivate(set) var isTerminated = false
    
    fileprivate(set) open var windows: [Window] = []
    internal var renderers: [Renderer] = []
    
    internal var eventQueue = [Event]()
    open fileprivate(set) var currentEvent: Event?
    
    internal fileprivate(set) var startTime = CFAbsoluteTimeGetCurrent()
    
    internal var runLoopSource: CFRunLoopSource? = nil
    
    internal var lastClickTimestamp: TimeInterval = .zero
    internal var clickCount: Int = .zero

    internal lazy var renderTimer: Timer = {
        return Timer(timeInterval: 1 / 60.0, repeats: true) { [unowned self] _ in
            if !isVulkanRendererEnabled {
                for i in 0..<self.windows.count {
                    self.renderers[i].render(window: self.windows[i])
                }

                self.displayServer.flush()
            }
        }
    }()

    // MARK: Initialization
    
    internal override init () {
        displayServer = DisplayServer(applicationName: "SwiftyFan")

        super.init()
    }
    
    open func window(number windowNumber: Int) -> Window? {
        return windows.indices.contains(windowNumber) ? windows[windowNumber] : nil
    }
    
    open fileprivate(set) var mainWindow: Window? = nil
    open fileprivate(set) var keyWindow: Window? = nil

    // MARK: Run Loop

    open func stop() {
        isRunning = false
        CFRunLoopStop(RunLoop.current.getCFRunLoop())
    }
    
    open func terminate() {
        isTerminated = true
        stop()
    }
    
    open func run() {
        if (delegate == nil) {
            fatalError("Who forgot to specify app delegate? You've forgot to specify app delegate.")
        }
        
        isRunning = true
        startTime = CFAbsoluteTimeGetCurrent()

        #if os(Linux)
        let trackingCFRunLoopMode = CFStringCreateWithCString(nil, RunLoop.Mode.tracking.rawValue, CFStringEncoding(kCFStringEncodingASCII))
        #else
        let trackingCFRunLoopMode = CFRunLoopMode(rawValue: RunLoop.Mode.tracking.rawValue as CFString)
        #endif
        CFRunLoopAddCommonMode(RunLoop.current.getCFRunLoop(), trackingCFRunLoopMode)

        displayServer.setupX11()

        RunLoop.current.add(renderTimer, forMode: .common)

        let _ = delegate?.application(self, willFinishLaunchingWithOptions: nil)
        let _ = delegate?.application(self, didFinishLaunchingWithOptions: nil)
        
        repeat {
            let event = nextEvent(matching: .any, until: Date.distantFuture, in: .default, dequeue: true)
            
            send(event: event)
            
            if isTerminated {
                break
            }
        } while isRunning

        renderTimer.invalidate()
        displayServer.destroyX11()
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
    
    open func nextEvent(matching mask: Event.EventTypeMask, until date: Date, in mode: RunLoop.Mode, dequeue: Bool) -> Event {
        var index = eventQueue.firstIndex(where: { mask.contains($0.type.mask) })
        
        while index == nil {
            let _ = RunLoop.current.run(mode: mode, before: date)
            
            if isRunning == false || isTerminated == true {
                return Event(withAppKidEventSubType: .terminate, windowNumber: NSNotFound)
            } else {
                index = eventQueue.firstIndex(where: { mask.contains($0.type.mask) })
            }
        }
        
        let result = eventQueue[index!]
        
        if dequeue {
            eventQueue.remove(at: index!)
        }
        
        return result
    }

    open func discardEvent(matching mask: Event.EventTypeMask, before event: Event) {
        guard let index = eventQueue.firstIndex(where: { $0.timestamp >= event.timestamp }) else { return }

        eventQueue.removeSubrange(0..<index)
    }

    // MARK: Windows

    open func add(window: Window) {
        windows.append(window)
        if !isVulkanRendererEnabled {
            renderers.append(window.createRenderer())
        }
    }

    open func remove(window: Window) {
        if let index = windows.firstIndex(of: window) {
            remove(windowNumer: index)
        }
    }

    open func remove(windowNumer index: Array<Window>.Index) {
        //palkovnik:TODO: order matters. renderer should always be destroyed before window is destroyed because renderer has strong reference to graphics context. this should change i.e. graphics context for particular window should be private to it's renderer
        if !isVulkanRendererEnabled {
            renderers.remove(at: index)
        }
        windows.remove(at: index)

        if windows.isEmpty && delegate?.applicationShouldTerminateAfterLastWindowClosed(self) == true {
            stop()
        }
    }
}

public extension Application {
    struct LaunchOptionsKey : Hashable, Equatable, RawRepresentable {
        public typealias RawValue = String
        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}
