//
//  X11DisplayServer+X11.swift
//  AppKid
//
//  Created by Serhii Mumriak on 01.02.2020.
//

import Foundation
import CoreFoundation

import CXlib
import SwiftXlib

internal let kEnableXInput2 = true

internal extension X11DisplayServer {
    func activate() {
        let fileHandle = FileHandle(fileDescriptor: display.connectionFileDescriptor, closeOnDealloc: false)

        eventQueueNotificationObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: fileHandle, queue: nil) { [unowned self] in
            self.hasEvents = true
            let fileHandle = $0.object as! FileHandle
            fileHandle.waitForDataInBackgroundAndNotify(forModes: [.default, .common, .tracking, .modal])
        }

        fileHandle.waitForDataInBackgroundAndNotify(forModes: [.default, .common, .tracking, .modal])

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
                fatalError("X11 error. Type: \(errorEvent.pointee.type), code: \(errorCode), code number: \(errorEvent.pointee.error_code)")
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
        display.withLocked { display in
            guard hasEvents == true else {
                return
            }

            guard XPending(display.pointer) != 0 else {
                hasEvents = false

                return
            }

            var x11Event = CXlib.XEvent()

            XNextEvent(display.pointer, &x11Event)

            let application = Application.shared

            let timestamp = CFAbsoluteTimeGetCurrent() - application.startTime

            let event: Event

            do {
                if x11Event.isCookie(with: display.xInput2ExtensionOpcode) {
                    if XGetEventData(display.pointer, &x11Event.xcookie) == 0 {
                        event = Event.ignoredDisplayServerEvent()
                    } else {
                        defer {
                            XFreeEventData(display.pointer, &x11Event.xcookie)
                        }

                        // smumriak:Hacking XInput2 event to have button number for motion events
                        if x11Event.xcookie.xInput2EventType == .motion {
                            x11Event.deviceEvent.detail = context.currentPressedMouseButton.rawValue
                        }

                        event = try Event(xInput2Event: x11Event, timestamp: timestamp, displayServer: self)
                    }
                } else {
                    event = try Event(x11Event: x11Event, timestamp: timestamp, displayServer: self)
                }
            } catch {
                event = Event.ignoredDisplayServerEvent()
            }

            switch event.type {
                case _ where event.isAnyMouseDownEvent && context.currentPressedMouseButton == .none:
                    context.currentPressedMouseButton = event.xInput2Button
                    event.window?.nativeWindow.updateListeningEvents()

                case _ where event.isAnyMouseUpEvent && context.currentPressedMouseButton == event.xInput2Button:
                    context.currentPressedMouseButton = .none
                    event.window?.nativeWindow.updateListeningEvents()

                default:
                    break
            }

            application.post(event: event, atStart: false)
        }
    }

    func updateInputDevices() {
        var count: CInt = 0
        guard let devicesArrayPointer = XIQueryDevice(display.pointer, XIAllDevices, &count) else {
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

                let deviceType: XInput2Device.DeviceType
                switch deviceInfo.use {
                    case XIMasterPointer, XISlavePointer:
                        deviceType = .pointer

                    case XIMasterKeyboard, XISlaveKeyboard:
                        deviceType = .keyboard

                    default:
                        fatalError("This code should never be executed")
                }

                return XInput2Device(identifier: deviceInfo.deviceid, valuatorsCount: valuatorsCount ?? 0, type: deviceType)
            }
    }
}
