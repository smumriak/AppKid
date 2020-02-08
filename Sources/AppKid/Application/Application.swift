//
//  Application.swift
//  AppKid
//
//  Created by Serhii Mumriak on 31/1/20.
//

import Foundation
import CoreFoundation
import CX11.Xlib
import CX11.X

#if os(Linux)
import CEpoll
import Glibc
#endif

public protocol ApplicationDelegate: class {}

open class Application: Responder {
    public static let shared = Application()
    unowned(unsafe) public var delegate: ApplicationDelegate?
    
    public fileprivate(set) var isRunning = false
    public fileprivate(set) var isTerminated = false
    
    internal(set) public var windows = [Window]()
    
    internal var eventQueue = [Event]()
    public fileprivate(set) var currentEvent: Event?
    
    internal fileprivate(set) var startTime = CFAbsoluteTimeGetCurrent()
    
    internal var display: UnsafeMutablePointer<CX11.Display>
    internal var screen: UnsafeMutablePointer<CX11.Screen>
    
    internal let rootWindow: Window
    
    internal var displayConnectionFileDescriptor: Int32 = -1
    internal var epollFileDescriptor: Int32 = -1
    internal var eventFileDescriptor: Int32 = -1
    internal var wmDeleteWindowAtom: CX11.Atom = UInt(CX11.None)
    
    internal lazy var pollThread = Thread { self.pollForX11Events() }
    
    internal var runLoopSource: CFRunLoopSource? = nil
    
    internal var lastClickTimestamp: TimeInterval = 0.0
    internal var clickCount: Int = 0
    
    internal override init () {
        guard let openDisplay = XOpenDisplay(nil) ?? XOpenDisplay(":0") else {
            fatalError("Could not open X display.")
        }
        
        display = openDisplay
        screen = XDefaultScreenOfDisplay(display)
        
        self.rootWindow = Window(x11Window: screen.pointee.root, display: display, screen: screen)
        
        displayConnectionFileDescriptor = XConnectionNumber(display)
        
        #if os(Linux)
        epollFileDescriptor = epoll_create1(Int32(EPOLL_CLOEXEC))
        if epollFileDescriptor == -1  {
            fatalError("Failed to create epoll file descriptor")
        }
        eventFileDescriptor = CEpoll.eventfd(0, Int32(CEpoll.EFD_CLOEXEC) | Int32(CEpoll.EFD_NONBLOCK))
        #else
        epollFileDescriptor = -1
        eventFileDescriptor = -1
        #endif
        
        wmDeleteWindowAtom = XInternAtom(display, "WM_DELETE_WINDOW".cString(using: .ascii), 0)
        
        super.init()
    }
    
    public func window(number windowNumber: Int) -> Window? {
        return windows.indices.contains(windowNumber) ? windows[windowNumber] : nil
    }
    
    public fileprivate(set) var mainWindow: Window? = nil
    public fileprivate(set) var keyWindow: Window? = nil
    
    public func finishLaunching() {
        
    }
    
    public func stop() {
        isRunning = false
        CFRunLoopStop(RunLoop.current.getCFRunLoop())
    }
    
    public func terminate() {
        isTerminated = true
        stop()
    }
    
    public func run() {
        if (delegate == nil) {
            fatalError("Who forgot to specify app delegate? You've forgot to specify app delegate.")
        }
        
        isRunning = true
        startTime = CFAbsoluteTimeGetCurrent()
        
        setupX11()
        
        #if DEBUG
//        addDebugRunLoopObserver()
        #endif
        
        addSimpleWindow()
        
        finishLaunching()
        
        repeat {
            let event = nextEvent(matching: .any, until: Date.distantFuture, in: .default, dequeue: true)
            
            send(event: event)
            
            if isTerminated {
                break
            }
        } while isRunning
        
        destroyX11()
    }
    
    public func post(event: Event, atStart: Bool) {
        eventQueue.insert(event, at: atStart ? 0 : eventQueue.count)
    }
    
    public func send(event: Event) {
        event.window?.send(event: event)
    }
    
    public func nextEvent(matching mask: Event.EventTypeMask, until date: Date, in mode: RunLoop.Mode, dequeue: Bool) -> Event {
        var index = eventQueue.firstIndex(where: { mask.contains($0.type.mask) })
        
        while index == nil {
            let _ = RunLoop.current.run(mode: mode, before: date)
            
            if isRunning == false || isTerminated == true {
                return Event(withAppKidEventSubType: .last)
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
    
    internal func addSimpleWindow() {
        let window = Window(contentRect: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 100.0))
        
        windows.append(window)
    }
    
    internal func add(window: Window) {
        windows.append(window)
    }
}
