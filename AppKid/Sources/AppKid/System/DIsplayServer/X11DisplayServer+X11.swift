//
//  X11DisplayServer+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import CoreFoundation

import CX11.Xlib
import CX11.X
import CXInput2

internal let kEnableXInput2 = true

internal extension X11DisplayServer {
    func activate() {
        context.displayConnectionFileDescriptor = XConnectionNumber(display)

        let fileHandle = FileHandle(fileDescriptor: context.displayConnectionFileDescriptor, closeOnDealloc: false)

        eventQueueNotificationObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: fileHandle, queue: nil) { [unowned self] in
            self.hasEvents = true
            let fileHandle = $0.object as! FileHandle
            fileHandle.waitForDataInBackgroundAndNotify(forModes: [.default, .common, .tracking])
        }

        fileHandle.waitForDataInBackgroundAndNotify(forModes: [.default, .common, .tracking])

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

        updateInputDevices()
    }
    
    func deactivate() {
        if let eventQueueNotificationObserver = eventQueueNotificationObserver {
            NotificationCenter.default.removeObserver(eventQueueNotificationObserver)

            self.eventQueueNotificationObserver = nil
        }

        context = X11DisplayServerContext()
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