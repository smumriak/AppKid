//
//  EventProcessor.swift
//  AppKid
//
//  Created by Serhii Mumriak on 08.07.2022
//

import Foundation
import TinyFoundation
import CoreFoundation
import CXlib
import SwiftXlib
import CairoGraphics

struct XlibEventProcessor: EventProcessor {
    typealias NativeEvent = XEvent
    typealias Context = X11DisplayServer

    enum Error: Swift.Error {
        case eventNotSupported
        case failedToGetEventData
        case foreignWindow
    }

    func process(event: NativeEvent, context: Context, timestamp: TimeInterval) throws -> Event {
        let display = context.display

        if event.isCookie(with: context.display.xInput2ExtensionOpcode) {
            var mutableEvent = event

            if XGetEventData(display.pointer, &mutableEvent.xcookie) == 0 {
                throw Error.failedToGetEventData
            } else {
                defer {
                    XFreeEventData(display.pointer, &mutableEvent.xcookie)
                }

                // smumriak:Hacking XInput2 event to have button number for motion events
                if mutableEvent.xcookie.xInput2EventType == .motion {
                    mutableEvent.deviceEvent.detail = context.context.currentPressedMouseButton.rawValue
                }

                return try processXInput2Event(mutableEvent, context: context, timestamp: timestamp)
            }
        } else {
            return try processRegularX11Event(event, context: context, timestamp: timestamp)
        }
    }
}

private extension XlibEventProcessor {
    @_transparent
    func processXInput2Event(_ event: NativeEvent, context: Context, timestamp: TimeInterval) throws -> Event {
        fatalError()
    }

    @_transparent
    func processRegularX11Event(_ event: NativeEvent, context: Context, timestamp: TimeInterval) throws -> Event {
        guard let windowNumber = context.nativeIdentifierToWindowNumber[event.xany.window] else {
            throw Error.foreignWindow
        }

        let result: Event

        switch event.eventType {
            case .mapNotify:
                result = Event(withAppKidEventSubType: .windowMapped, windowNumber: windowNumber)

            case .unmapNotify:
                result = Event(withAppKidEventSubType: .windowUnmapped, windowNumber: windowNumber)
                
            case .expose:
                result = Event(withAppKidEventSubType: .windowExposed, windowNumber: windowNumber)
                
            case .clientMessage:
                result = Event(clientMessageEvent: event.xclient, timestamp: timestamp, displayServer: context, windowNumber: windowNumber)

            case .configureNotify:
                let configureEvent = event.xconfigure

                result = Event(withAppKidEventSubType: .configurationChanged, windowNumber: windowNumber)
                result.deltaX = CGFloat(configureEvent.width) / context.context.scale
                result.deltaY = CGFloat(configureEvent.height) / context.context.scale
                
            default:
                throw Error.eventNotSupported
        }

        return result
    }
}
