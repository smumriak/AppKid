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

internal let testString = "And if you gaze long into an abyss, the abyss also gazes into you."

internal extension Application {
    func setupX11() {
        displayConnectionFileDescriptor = XConnectionNumber(display)

        #if os(Linux)
        epollFileDescriptor = epoll_create1(CInt(EPOLL_CLOEXEC))
        if epollFileDescriptor == -1  {
            fatalError("Failed to create epoll file descriptor")
        }
        eventFileDescriptor = CEpoll.eventfd(0, CInt(CEpoll.EFD_CLOEXEC) | CInt(CEpoll.EFD_NONBLOCK))
        #else
        epollFileDescriptor = -1
        eventFileDescriptor = -1
        #endif

        wmDeleteWindowAtom = XInternAtom(display, "WM_DELETE_WINDOW".cString(using: .ascii), 0)

        XSetErrorHandler { display, event -> CInt in
            Application.shared.terminate()
            return 0
        }

        XSetIOErrorHandler { display -> CInt in
            Application.shared.terminate()
            return 0
        }

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
                let application: Application = Unmanaged.fromOpaque(info).takeUnretainedValue()
                return UnsafeMutableRawPointer(bitPattern: Int(application.eventFileDescriptor))
            } else {
                return UnsafeMutableRawPointer(bitPattern: Int(-1))
            }
        }
        
        x11RunLoopSourceContext.perform = {
            if let info = $0 {
                let application: Application = Unmanaged.fromOpaque(info).takeUnretainedValue()
                application.processX11EventsQueue()
            }
        }
        #endif
        
        let x11RunLoopSourceContextPointer = UnsafeMutableRawPointer(&x11RunLoopSourceContext).bindMemory(to: CFRunLoopSourceContext.self, capacity: 1)
        
        runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, x11RunLoopSourceContextPointer)

        let currentRunloop = RunLoop.current
        CFRunLoopAddSource(currentRunloop.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)
        currentRunloop.add(renderTimer, forMode: .common)
        
        pollThread.qualityOfService = .userInteractive
        pollThread.name = "X11 poll thread"
        pollThread.start()
    }
    
    func destroyX11(){
        pollThread.cancel()

        renderTimer.invalidate()
        CFRunLoopRemoveSource(RunLoop.current.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)

        wmDeleteWindowAtom = CUnsignedLong(CX11.None)
        
        if eventFileDescriptor != -1 {
            close(eventFileDescriptor)
            eventFileDescriptor = -1
        }
        if epollFileDescriptor != -1 {
            close(epollFileDescriptor)
            epollFileDescriptor = -1
        }
        
        displayConnectionFileDescriptor = -1
    }
    
    func pollForX11Events() {
        if Thread.isMainThread {
            fatalError("Polling of X11 events is not allowed on main thread. Never. It's an infinite loop, you don't want to block your main thread, do you?")
        }
        #if os(Linux)
        var awokenEvent = epoll_event()
        var one: UInt64 = 1
        while pollThread.isCancelled == false || pollThread.isFinished == false {
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
            
            guard let windowNumber = Application.shared.windows.firstIndex(where: { $0.nativeWindow.windowID == x11Event.xany.window }) else {
                continue
            }
            
            let timestamp = CFAbsoluteTimeGetCurrent() - Application.shared.startTime
            
            if let event = try? Event(x11Event: x11Event, timestamp: timestamp, windowNumber: windowNumber) {
                if event.type == .noEvent {
                    continue
                }
                
                if event.type == .appKidDefined {
                    if event.subType == .message {
                        if CX11.Atom(x11Event.xclient.data.l.0) == wmDeleteWindowAtom {
                            Application.shared.remove(windowNumer: windowNumber)
                            return
                        }
                    }
                }
                
                post(event: event, atStart: false)
            } else {
                switch x11Event.type {
                default:
                    break
                }
            }
        }
    }
}

extension Application {
    func addDebugRunLoopObserver() {
        #if os(Linux)
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFOptionFlags(kCFRunLoopAllActivities), true, 0) { _, activity in
            switch Int(activity) {
            case kCFRunLoopEntry:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity kCFRunLoopEntry")
            case kCFRunLoopBeforeTimers:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity kCFRunLoopBeforeTimers")
            case kCFRunLoopBeforeSources:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity kCFRunLoopBeforeSources")
            case kCFRunLoopBeforeWaiting:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity kCFRunLoopBeforeWaiting")
            case kCFRunLoopAfterWaiting:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity kCFRunLoopAfterWaiting")
            case kCFRunLoopExit:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity kCFRunLoopExit")
            case kCFRunLoopAllActivities:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity kCFRunLoopAllActivities")
            default:
                debugPrint("\(CFAbsoluteTimeGetCurrent()): Run Loop Activity UNKNOWN")
            }
        }
        
        CFRunLoopAddObserver(RunLoop.current.getCFRunLoop(), observer, CFRunLoopCommonModesConstant)
        #endif
    }
}
