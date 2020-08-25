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
    func activate() {
        context.displayConnectionFileDescriptor = XConnectionNumber(display)

        do {
            context.displayConnectionWaitSignal = try EpollWaitSignal(waitFileDescriptor: context.displayConnectionFileDescriptor)
        } catch {
            XCloseDisplay(display)
            fatalError("Failed to create epoll file descriptor, error: \(error)")
        }

        context.deleteWindowAtom = XInternAtom(display, "WM_DELETE_WINDOW", 0)
        context.takeFocusAtom = XInternAtom(display, "WM_TAKE_FOCUS", 0)
        context.xiTouchPadAtom = XInternAtom(display, XI_TOUCHPAD, 0)
        context.xiMouseAtom = XInternAtom(display, XI_MOUSE, 0)
        context.xiKeyvoardAtom = XInternAtom(display, XI_KEYBOARD, 0)
        context.syncRequestAtom = XInternAtom(display, "_NET_WM_SYNC_REQUEST", 0)

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
        x11RunLoopSourceContext.info = Unmanaged.passUnretained(self).toOpaque()
        
        #if os(Linux)
        x11RunLoopSourceContext.getPort = {
            if let info = $0 {
                let displayServer: DisplayServer = Unmanaged<DisplayServer>.fromOpaque(info).takeUnretainedValue()
                
                return UnsafeMutableRawPointer(bitPattern: Int(displayServer.context.displayConnectionWaitSignal.signalFileDescriptor))
            } else {
                return UnsafeMutableRawPointer(bitPattern: Int(-1))
            }
        }
        
        x11RunLoopSourceContext.perform = {
            if let info = $0 {
                let displayServer: DisplayServer = Unmanaged<DisplayServer>.fromOpaque(info).takeUnretainedValue()
                
                displayServer.handleX11EpollSignal()
            }
        }
        #endif

        let currentRunloop = RunLoop.current

        withUnsafeMutablePointer(to: &x11RunLoopSourceContext) {
            $0.withMemoryRebound(to: CFRunLoopSourceContext.self, capacity: 1) {
                runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, $0)!
                
                CFRunLoopAddSource(currentRunloop.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)
            }
        }

        pollThread.qualityOfService = .userInteractive
        pollThread.name = "X11 poll thread"
        pollThread.start()

        updateInputDevices()
    }
    
    func deactivate() {
        pollThread.cancel()

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(RunLoop.current.getCFRunLoop(), runLoopSource, CFRunLoopCommonModesConstant)
        }

        context = DisplayServerContext()
    }
    
    func pollForX11Events() {
        if Thread.isMainThread {
            XCloseDisplay(display)
            fatalError("Polling of X11 events is not allowed on main thread. Never. It's an infinite loop, you don't want to block your main thread, do you?")
        }
        while pollThread.isCancelled == false && pollThread.isFinished == false {
            let result = context.displayConnectionWaitSignal.wait()
            if result.result == 0 || result.result == -1 { continue }
            context.displayConnectionWaitSignal.signal()
        }
    }

    func handleX11EpollSignal() {
        hasEvents = true
    }

    func serviceEventsQueue() {
        guard hasEvents == true else {
            return
        }

        guard XPending(display) != 0 else {
            hasEvents = false

            return
        }

        var x11Event = CX11.XEvent()

        XNextEvent(display, &x11Event)

        let application = Application.shared

        let timestamp = CFAbsoluteTimeGetCurrent() - application.startTime

        let event: Event

        do {
            if x11Event.isCookie(with: context.xInput2ExtensionOpcode)  {
                if XGetEventData(display, &x11Event.xcookie) == 0 {
                    event = Event.ignoredDisplayServerEvent()
                } else {
                    defer {
                        XFreeEventData(display, &x11Event.xcookie)
                    }

                    //palkovnik:Hacking XInput2 event to have button number for motion events
                    if x11Event.xcookie.xInput2EventType == .motion {
                        x11Event.deviceEvent.detail = context.currentPressedMouseButton.rawValue
                    }

                    event = try Event(xInput2Event: x11Event, timestamp: timestamp, displayServer: self)
                }
            } else {
                event = try Event(x11Event: x11Event, timestamp: timestamp, displayServer: self)
            }
        } catch {
//            debugPrint("Failed to parse X11 Event with error: \(error)")
            event = Event.ignoredDisplayServerEvent()
        }

        switch event.type {
        case _ where event.isAnyMouseDownEvent && context.currentPressedMouseButton == .none:
            context.currentPressedMouseButton = event.xInput2Button

        case _ where event.isAnyMouseUpEvent && context.currentPressedMouseButton == event.xInput2Button:
            context.currentPressedMouseButton = .none

        default:
            break
        }

        application.post(event: event, atStart: false)
    }

    func updateInputDevices() {
        var count: CInt = 0
        guard let devicesArrayPointer = XIQueryDevice(display, XIAllDevices, &count) else {
            context.inputDevices = []
            return
        }

        defer {
            XIFreeDeviceInfo(devicesArrayPointer)
        }

        context.inputDevices = UnsafeBufferPointer(start: devicesArrayPointer, count: Int(count))
            .filter { [XISlavePointer, XIMasterKeyboard].contains($0.use) }
            .map { deviceInfo in
                let valuatorsCount = deviceInfo.classes.map {
                    UnsafeBufferPointer(start: $0, count: Int(deviceInfo.num_classes))
                        .compactMap { $0?.pointee }
                        .filter { $0.type == XIValuatorClass }
                        .count
                }.map {
                    CInt($0)
                }

                let deviceType: XInput2Device.DeviceType = {
                    if deviceInfo.use == XISlavePointer {
                        return .pointer
                    } else {
                        return .keyboard
                    }
                }()

                return XInput2Device(identifier: deviceInfo.deviceid, valuatorsCount: valuatorsCount ?? 0, type: deviceType)
        }
    }
}
