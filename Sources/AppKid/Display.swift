//
//  Display.swift
//  AppKid
//
//  Created by Serhii Mumriak on 5/2/20.
//

import Foundation
import CoreFoundation
import CX11.Xlib
import CX11.X

#if os(Linux)
import CEpoll
import Glibc
#endif

internal let helloWorldString = "Hello, world!"

open class Display {
    internal var eventQueue = [Event]()
    
    internal var display: UnsafeMutablePointer<CX11.Display>
    internal var screen: UnsafeMutablePointer<CX11.Screen>
    
    internal let rootWindow: Window
    
    internal var displayConnectionFileDescriptor: Int32
    internal var epollFileDescriptor: Int32
    internal var eventFileDescriptor: Int32
    internal var wmDeleteWindowAtom: CX11.Atom
    
    internal lazy var pollThread = Thread { self.pollForX11Events() }
    
    internal var runLoopSource: CFRunLoopSource? = nil
    
    internal var lastClickTimestamp: TimeInterval = 0.0
    internal var clickCount: Int = 0
    
    deinit {
        destroyX11()
        close(eventFileDescriptor)
        close(epollFileDescriptor)
        XCloseDisplay(display)
    }
    
    public init() {
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
        
        pollThread.qualityOfService = .userInteractive
        pollThread.name = "X11 poll thread"
        
        setupX11()
    }
    
    public func nextEvent(matching mask: Event.EventTypeMask, until date: Date, in mode: RunLoop.Mode, dequeue: Bool) -> Event {
        let _ = RunLoop.current.run(mode: mode, before: eventQueue.isEmpty ? date : Date())
        
        var result: Event? = nil
        
        while result == nil && eventQueue.isEmpty == false {
            if mask.contains(eventQueue[0].type.mask) {
                result = eventQueue.removeFirst()
            } else {
                _ = eventQueue.removeFirst()
            }
        }
        
        return result ?? Event(type: .appKidDefined, location: CGPoint.zero, modifierFlags: .none, window: nil)
    }
    
    public func post(event: Event, atStart: Bool) {
        eventQueue.insert(event, at: atStart ? 0 : eventQueue.count)
    }
}

internal extension Display {
    func setupX11() {
        var x11RunLoopSourceContext = CFRunLoopSourceContext1()
        x11RunLoopSourceContext.version = 1
        x11RunLoopSourceContext.info = Unmanaged.passRetained(self).toOpaque()
        
        #if os(Linux)
        var x11EpollEvent = epoll_event()
        x11EpollEvent.events = EPOLLIN.rawValue | EPOLLET.rawValue
        x11EpollEvent.data.fd = displayConnectionFileDescriptor
        
        guard epoll_ctl(epollFileDescriptor, EPOLL_CTL_ADD, displayConnectionFileDescriptor, &x11EpollEvent) == 0 else {
            close(epollFileDescriptor)
            fatalError("Failed to add file descriptor to epoll")
        }
        
        x11RunLoopSourceContext.getPort = {
            if let info = $0 {
                let display: Display = Unmanaged.fromOpaque(info).takeUnretainedValue()
                return UnsafeMutableRawPointer(bitPattern: Int(display.eventFileDescriptor))
            } else {
                return UnsafeMutableRawPointer(bitPattern: Int(-1))
            }
        }
        
        x11RunLoopSourceContext.perform = {
            if let info = $0 {
                let display: Display = Unmanaged.fromOpaque(info).takeUnretainedValue()
                display.processX11EventsQueue()
            }
        }
        #endif
        
        let x11RunLoopSourceContextPointer = UnsafeMutableRawPointer(&x11RunLoopSourceContext).bindMemory(to: CFRunLoopSourceContext.self, capacity: 1)
        
        runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, x11RunLoopSourceContextPointer)
        
        CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)
        
        pollThread.start()
    }
    
    func destroyX11(){
        CFRunLoopRemoveSource(RunLoop.current.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)
    }
    
    func pollForX11Events() {
        if Thread.isMainThread {
            fatalError("Polling of X11 events is not allowed on main thread. Never. It's an infinite loop, you don't want to block your main thread, do you?")
        }
        #if os(Linux)
        var awokenEvent = epoll_event()
        var one: UInt64 = 1
        while true {
            let result = CEpoll.epoll_wait(epollFileDescriptor, &awokenEvent, 1, -1)
            if (result == 0 || result == -1) { continue }
            CEpoll.write(eventFileDescriptor, &one, 8)
        }
        #endif
    }
    
    func processX11EventsQueue() {
        var x11Event = CX11.XEvent()
        while XPending(display) != 0 {
            XNextEvent(display, &x11Event)
            
            guard let windowNumber = Application.shared.windows.firstIndex(where: { $0.x11Window == x11Event.xany.window }) else {
                continue
            }
            
            let window = Application.shared.windows[windowNumber]
            let timestamp = CFAbsoluteTimeGetCurrent() - Application.shared.startTime
            
            if let event = try? Event(x11Event: x11Event, timestamp: timestamp, windowNumber: windowNumber) {
                if event.type == .noEvent {
                    continue
                }
                
                post(event: event, atStart: false)
            } else {
                switch x11Event.type {
                case Expose:
                    XDrawString(display, window.x11Window, screen.pointee.default_gc, 10, 70, helloWorldString, Int32(helloWorldString.count))
                    XFlush(display)
                    
                case KeyPress:
                    let blackColor = XBlackPixelOfScreen(screen)
                    XSetForeground(display, screen.pointee.default_gc, blackColor)
                    XFillRectangle(display, window.x11Window, screen.pointee.default_gc, 20, 20, 10, 10)
                    XFlush(display)
                    break
                    
                case KeyRelease:
                    let whiteColor = XWhitePixelOfScreen(screen)
                    XSetForeground(display, screen.pointee.default_gc, whiteColor)
                    XFillRectangle(display, window.x11Window, screen.pointee.default_gc, 20, 20, 10, 10)
                    XFlush(display)
                    break
                    
                case ButtonPress:
                    break
                    
                case ButtonRelease:
                    break
                    
                case ClientMessage:
                    if CX11.Atom(x11Event.xclient.data.l.0) == wmDeleteWindowAtom {
                        Application.shared.windows.remove(at: windowNumber)
                    }
                    
                default:
                    break
                }
            }
        }
    }
}
