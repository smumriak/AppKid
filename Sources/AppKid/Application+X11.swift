//
//  Application+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 1/2/20.
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

internal extension Application {
    func setupX() {
        #if os(Linux)
        debugPrint("Setup X system")
        
        XInitThreads()
        
        x11EpollFileDecriptor = epoll_create1(Int32(EPOLL_CLOEXEC))
        if x11EpollFileDecriptor == -1  {
            fatalError("Failed to create epoll file descriptor")
        }
        
        debugPrint("Finished setting up epoll file descriptor: \(x11EpollFileDecriptor)")
        
        var x11EpollEvent = epoll_event()
        x11EpollEvent.events = EPOLLIN.rawValue | EPOLLET.rawValue
        x11EpollEvent.data.fd = x11FileDescriptor
        
        guard epoll_ctl(x11EpollFileDecriptor, EPOLL_CTL_ADD, x11FileDescriptor, &x11EpollEvent) == 0 else {
            close(x11EpollFileDecriptor)
            fatalError("Failed to add file descriptor to epoll")
        }
        
        debugPrint("Finished epoll_ctl")
        
        var x11RunLoopSourceContext = CFRunLoopSourceContext1()
        x11RunLoopSourceContext.version = 1
        x11RunLoopSourceContext.info = Unmanaged.passRetained(self).toOpaque()
        
        x11RunLoopSourceContext.getPort = {
            debugPrint("getPort callback")
            
            if let info = $0 {
                let application: Application = Unmanaged.fromOpaque(info).takeUnretainedValue()
                let result = UnsafeMutableRawPointer(bitPattern: Int(application.x11EventFileDescriptor))
                
                debugPrint("getPort result: \(String(describing: result))")
                
                return result
            } else {
                return UnsafeMutableRawPointer(bitPattern: Int(-1))
            }
        }
        
        x11RunLoopSourceContext.perform = {
            debugPrint("perform callback")
            
            if let info = $0 {
                let application: Application = Unmanaged.fromOpaque(info).takeUnretainedValue()
                application.processX11EventsQueue()
            }
        }
        
        let x11RunLoopSourceContextPointer = UnsafeMutableRawPointer(&x11RunLoopSourceContext).bindMemory(to: CFRunLoopSourceContext.self, capacity: 1)
        
        let x11RunLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, x11RunLoopSourceContextPointer)
        
        CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), x11RunLoopSource, CFRunLoopCommonModesConstant)
        
        x11EpollThread.start()
        #endif
    }
    
    func processX11EventsQueue() {
        var x11Event = CX11._XEvent()
        while XPending(display) != 0 {
            XNextEvent(display, &x11Event)
            
            guard let windowIndex = windows.firstIndex(where: { $0.x11Window == x11Event.xany.window }) else {
                continue
            }
            
            let window = windows[windowIndex]
            
            switch x11Event.type {
            case Expose:
                XFillRectangle(display, window.x11Window, screen.pointee.default_gc, 20, 20, 10, 10)
                XDrawString(display, window.x11Window, screen.pointee.default_gc, 10, 70, helloWorldString, Int32(helloWorldString.count))
                
            case KeyPress:
                debugPrint("KeyPress. I'm too lazy to load key data. Yet")
                
            case ClientMessage:
                if CX11.Atom(x11Event.xclient.data.l.0) == self.x11WMDeleteWindowAtom {
                    debugPrint("Window was closed")
                    windows.remove(at: windowIndex)
                }
                
            default:
                fatalError("Wrong event handled")
            }
        }
    }
    
    func addSimpleWindow() {
        let window = Window(contentRect: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 100.0))
        
        self.windows.append(window)
    }
    
    func addDebugRunLoopObserver() {
        #if os(Linux)
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFOptionFlags(kCFRunLoopAllActivities), true, 0) { _, activity in
            switch Int(activity) {
            case kCFRunLoopEntry:
                debugPrint("Run Loop Activity kCFRunLoopEntry")
            case kCFRunLoopBeforeTimers:
                debugPrint("Run Loop Activity kCFRunLoopBeforeTimers")
            case kCFRunLoopBeforeSources:
                debugPrint("Run Loop Activity kCFRunLoopBeforeSources")
            case kCFRunLoopBeforeWaiting:
                debugPrint("Run Loop Activity kCFRunLoopBeforeWaiting")
            case kCFRunLoopAfterWaiting:
                debugPrint("Run Loop Activity kCFRunLoopAfterWaiting")
            case kCFRunLoopExit:
                debugPrint("Run Loop Activity kCFRunLoopExit")
            case kCFRunLoopAllActivities:
                debugPrint("Run Loop Activity kCFRunLoopAllActivities")
            default:
                debugPrint("Run Loop Activity UNKNOWN")
            }
        }
        
        debugPrint("Add observer")
        CFRunLoopAddObserver(RunLoop.current.getCFRunLoop(), observer, CFRunLoopCommonModesConstant)
        debugPrint("Added observer")
        #endif
    }
    
    func pollForX11Events() {
        if Thread.isMainThread {
            fatalError("Polling of X11 events is not allowed on main thread. Never. It's an infinite loop, you don't want to block your main thread, do you?")
        }
        #if os(Linux)
        debugPrint("Starting the thread")
        var awokenEvent = epoll_event()
        while true {
            debugPrint("Polling for X11 events on \(self.x11EpollFileDecriptor)")
            let result = CEpoll.epoll_wait(self.x11EpollFileDecriptor, &awokenEvent, 1, -1)
            
            if (result == 0 || result == -1) {
                debugPrint("Continue after bad poll")
                continue
            }
            
            debugPrint("Got X11 event")
            
            debugPrint("Firing event")
            var one: UInt64 = 1
            CEpoll.write(self.x11EventFileDescriptor, &one, 8)
        }
        #endif
    }
}
