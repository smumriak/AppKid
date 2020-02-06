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

open class Application {
    public static let shared = Application()
    unowned(unsafe) public var delegate: ApplicationDelegate?
    
    public fileprivate(set) var isRunning = false
    public fileprivate(set) var isTerminated = false
    
    internal(set) public var windows = [Window]()
    internal(set) public var display: Display
    
    internal fileprivate(set) var startTime = CFAbsoluteTimeGetCurrent()
    
    internal init () {
        self.display = Display()
    }
    
    public func window(number windowNumber: Int) -> Window? {
        return windows.indices.contains(windowNumber) ? windows[windowNumber] : nil
    }
    
    public fileprivate(set) var mainWindow: Window? = nil
    public fileprivate(set) var keyWindow: Window? = nil
    
    public func finishLaunching() {
        
    }
    
    public func stop() {
        isRunning = true
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
        
        #if DEBUG
//        addDebugRunLoopObserver()
        #endif
        
        addSimpleWindow()
        
        finishLaunching()
        
        repeat {
            let event = nextEvent(matching: .any, until: Date.distantFuture, in: .default, dequeue: true)
            
            send(event: event)
            
            if isTerminated {
                return
            }
        } while isRunning
    }
    
    public func post(event: Event, atStart: Bool) {
        display.post(event: event, atStart: atStart)
    }
    
    public func send(event: Event) {
        event.window?.send(event: event)
    }
    
    public func nextEvent(matching mask: Event.EventTypeMask, until date: Date, in mode: RunLoop.Mode, dequeue: Bool) -> Event {
        return display.nextEvent(matching: mask, until: date, in: mode, dequeue: dequeue)
    }
    
    internal func addSimpleWindow() {
        let window = Window(contentRect: CGRect(x: 10.0, y: 10.0, width: 200.0, height: 100.0))
        
        windows.append(window)
    }
    
    internal func add(window: Window) {
        windows.append(window)
    }
}
