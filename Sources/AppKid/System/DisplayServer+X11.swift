//
//  DisplayServer+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import CoreFoundation
import CX11.Xlib
import CX11.X
import CXInput2

#if os(Linux)
import CEpoll
import Glibc
#endif

internal extension DisplayServer {
    func setupX11() {
        x11Context.displayConnectionFileDescriptor = XConnectionNumber(display)

        #if os(Linux)
        x11Context.epollFileDescriptor = epoll_create1(CInt(EPOLL_CLOEXEC))
        if x11Context.epollFileDescriptor == -1  {
            XCloseDisplay(display)
            fatalError("Failed to create epoll file descriptor")
        }
        x11Context.eventFileDescriptor = CEpoll.eventfd(0, CInt(CEpoll.EFD_CLOEXEC) | CInt(CEpoll.EFD_NONBLOCK))
        #endif

        x11Context.wmDeleteWindowAtom = XInternAtom(display, "WM_DELETE_WINDOW".cString(using: .ascii), 0)

        XSetErrorHandler { display, errorEvent -> CInt in
            if let errorEvent = errorEvent {
                let errorCode: String = {
                    switch Int32(errorEvent.pointee.error_code) {
                    case BadAccess: return "BadAccess"
                    case BadAlloc: return "BadAlloc"
                    case BadAtom: return "BadAtom"
                    case BadColor: return "BadColor"
                    case BadCursor: return "BadCursor"
                    case BadDrawable: return "BadDrawable"
                    case BadFont: return "BadFont"
                    case BadGC: return "BadGC"
                    case BadIDChoice: return "BadIDChoice"
                    case BadImplementation: return "BadImplementation"
                    case BadLength: return "BadLength"
                    case BadMatch: return "BadMatch"
                    case BadName: return "BadName"
                    case BadPixmap: return "BadPixmap"
                    case BadRequest: return "BadRequest"
                    case BadValue: return "BadValue"
                    case BadWindow: return "BadWindow"
                    default: return "Unknown"
                    }
                }()
                debugPrint("X11 error. Type: \(errorEvent.pointee.type), code: \(errorCode), code number: \(errorEvent.pointee.error_code)")
            }
            Application.shared.terminate()
            return 0
        }

        XSetIOErrorHandler { display -> CInt in
            debugPrint("Some X11 IO error.")
            Application.shared.terminate()
            return 0
        }

        var x11RunLoopSourceContext = CFRunLoopSourceContext1()
        x11RunLoopSourceContext.version = 1
        x11RunLoopSourceContext.info = Unmanaged.passRetained(self).toOpaque()
        
        #if os(Linux)
        var x11EpollEvent = epoll_event()
        x11EpollEvent.events = EPOLLIN.rawValue | EPOLLET.rawValue
        x11EpollEvent.data.fd = x11Context.displayConnectionFileDescriptor
        
        guard epoll_ctl(x11Context.epollFileDescriptor, EPOLL_CTL_ADD, x11Context.displayConnectionFileDescriptor, &x11EpollEvent) == 0 else {
            close(x11Context.epollFileDescriptor)
            XCloseDisplay(display)
            fatalError("Failed to add file descriptor to epoll")
        }
        
        x11RunLoopSourceContext.getPort = {
            if let info = $0 {
                let displayServer: DisplayServer = Unmanaged.fromOpaque(info).takeUnretainedValue()
                return UnsafeMutableRawPointer(bitPattern: Int(displayServer.x11Context.eventFileDescriptor))
            } else {
                return UnsafeMutableRawPointer(bitPattern: Int(-1))
            }
        }
        
        x11RunLoopSourceContext.perform = {
            if let info = $0 {
                let displayServer: DisplayServer = Unmanaged.fromOpaque(info).takeUnretainedValue()
                displayServer.processX11EventsQueue()
            }
        }
        #endif

        let currentRunloop = RunLoop.current

        let runLoopSource: CFRunLoopSource = withUnsafeMutablePointer(to: &x11RunLoopSourceContext) {
            let x11RunLoopSourceContextPointer = UnsafeMutableRawPointer($0).bindMemory(to: CFRunLoopSourceContext.self, capacity: 1)

            return CFRunLoopSourceCreate(kCFAllocatorDefault, 0, x11RunLoopSourceContextPointer)!
        }

        CFRunLoopAddSource(currentRunloop.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)

        pollThread.qualityOfService = .userInteractive
        pollThread.name = "X11 poll thread"
        pollThread.start()
    }
    
    func destroyX11(){
        pollThread.cancel()

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(RunLoop.current.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)
        }

        if x11Context.eventFileDescriptor != -1 {
            close(x11Context.eventFileDescriptor)
        }
        if x11Context.epollFileDescriptor != -1 {
            close(x11Context.epollFileDescriptor)
        }

        x11Context = X11Context()
    }
    
    func pollForX11Events() {
        if Thread.isMainThread {
            XCloseDisplay(display)
            fatalError("Polling of X11 events is not allowed on main thread. Never. It's an infinite loop, you don't want to block your main thread, do you?")
        }
        #if os(Linux)
        var awokenEvent = epoll_event()
        var one: UInt64 = 1
        while pollThread.isCancelled == false || pollThread.isFinished == false {
            let result = CEpoll.epoll_wait(x11Context.epollFileDescriptor, &awokenEvent, 1, -1)
            if (result == 0 || result == -1) { continue }
            CEpoll.write(x11Context.eventFileDescriptor, &one, 8)
        }
        #endif
    }
    
    func processX11EventsQueue() {
        var x11Event = CX11.XEvent()
        
        while XPending(display) != 0 {
            XNextEvent(display, &x11Event)

            let application = Application.shared

            let timestamp = CFAbsoluteTimeGetCurrent() - application.startTime

            let event: Event

            do {
                if x11Event.isCookie(with: x11Context.xInput2ExtensionOpcode)  {
                    guard XGetEventData(display, &x11Event.xcookie) != 0 else { continue }

                    defer {
                        XFreeEventData(display, &x11Event.xcookie)
                    }

                    //palkovnik:Hacking XInput2 event to have button number for motion events
                    if x11Event.xcookie.xInput2EventType == .motion {
                        x11Event.deviceEvent.detail = x11Context.currentPressedMouseButton.rawValue
                    }

                    event = try Event(xInput2Event: x11Event, timestamp: timestamp, displayServer: self)
                } else {
                    event = try Event(x11Event: x11Event, timestamp: timestamp, displayServer: self)
                }
            } catch {
//                debugPrint("Failed to pase X11 Event with error: \(error)")
                continue
            }
            
            if event.type == .noEvent {
                continue
            }

            if event.type == .appKidDefined {
                if event.subType == .message {
                    if CX11.Atom(x11Event.xclient.data.l.0) == x11Context.wmDeleteWindowAtom {
                        application.remove(windowNumer: event.windowNumber)
                        return
                    }
                }
            }

            switch event.type {
            case _ where event.isAnyMouseDownEvent && x11Context.currentPressedMouseButton == .none:
                x11Context.currentPressedMouseButton = event.xInput2Button

            case _ where event.isAnyMouseUpEvent && x11Context.currentPressedMouseButton == event.xInput2Button:
                x11Context.currentPressedMouseButton = .none

            default:
                break
            }

            application.post(event: event, atStart: false)
        }
    }
}
