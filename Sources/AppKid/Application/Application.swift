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
import CairoGraphics

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
    
    internal var lastClickTimestamp: TimeInterval = .zero
    internal var clickCount: Int = .zero
    
    internal override init () {
        guard let openDisplay = XOpenDisplay(nil) ?? XOpenDisplay(":0") else {
            fatalError("Could not open X display.")
        }
        
        display = openDisplay
        screen = XDefaultScreenOfDisplay(display)
        
        var rootWindowAttributes = XWindowAttributes()
        if XGetWindowAttributes(display, screen.pointee.root, &rootWindowAttributes) == 0 {
            fatalError("Can not get root window attributes")
        }
        let nativeRootWindow = X11NativeWindow(display: display, screen: screen, windowID: screen.pointee.root, rootWindowID: nil)
        self.rootWindow = Window(nativeWindow: nativeRootWindow)
        
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
                return Event(withAppKidEventSubType: .last, windowNumber: NSNotFound)
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
        let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
        
        windows.append(window)
        
        let subview1 = View(with: CGRect(x: 20.0, y: 20.0, width: 100.0, height: 100.0))
        subview1.tag = 1
        subview1.backgroundColor = .green
        subview1.transform = CairoGraphics.CGAffineTransform.identity.rotated(by: .pi / 2)
        
        let subview2 = View(with: CGRect(x: 20.0, y: 20.0, width: 60.0, height: 60.0))
        subview2.tag = 2
        subview2.backgroundColor = .red
        subview2.transform = CairoGraphics.CGAffineTransform.identity.rotated(by: .pi / 2)

        let subview3 = View(with: CGRect(x: 20.0, y: 20.0, width: 20.0, height: 20.0))
        subview3.tag = 3
        subview3.backgroundColor = .gray
        subview3.transform = CairoGraphics.CGAffineTransform.identity.rotated(by: .pi)

        subview2.add(subview: subview3)
        subview1.add(subview: subview2)

        let label = Label(with: window.bounds)
        label.backgroundColor = .clear
        label.text = testString

        let subview4 = View(with: CGRect(x: 300.0, y: 200.0, width: 20.0, height: 80.0))
        subview4.tag = 4
        subview4.backgroundColor = .blue
        window.add(subview: subview4)

        let _ = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak window, weak subview1, weak subview2, weak subview3]  _ in
            subview1?.transform = subview1?.transform.rotated(by: .pi / 120) ?? .identity
            subview2?.transform = subview2?.transform.rotated(by: -.pi / 80) ?? .identity
            subview3?.transform = subview3?.transform.rotated(by: .pi / 20) ?? .identity
            window?.render()
        }
        
        window.add(subview: subview1)

        window.add(subview: label)
    }
    
    internal func add(window: Window) {
        windows.append(window)
    }
}
