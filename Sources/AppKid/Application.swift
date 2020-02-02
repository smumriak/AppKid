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
    public typealias Display = UnsafeMutablePointer<CX11.Display>
    public typealias Screen = UnsafeMutablePointer<CX11.Screen>
    
    public static let shared = Application()
    unowned(unsafe) public var delegate: ApplicationDelegate?
    
    internal(set) public var windows = [Window]()
    internal(set) public var display: Display
    internal(set) public var screen: Screen
    
    internal let rootWindow: Window
    internal let x11FileDescriptor: Int32
    internal var x11WMDeleteWindowAtom: CX11.Atom
    
    #if os(Linux)
    internal var x11EpollFileDecriptor: Int32 = -1
    internal let x11EventFileDescriptor = CEpoll.eventfd(0, Int32(CEpoll.EFD_CLOEXEC) | Int32(CEpoll.EFD_NONBLOCK))
    internal lazy var x11EpollThread = Thread { self.pollForX11Events() }
    #endif
    
    internal init () {
        debugPrint("App initialization")
        
        guard let display = XOpenDisplay(nil) else {
            fatalError("Could not open X display.")
        }
        
        debugPrint("Opened display: \(String(describing: display))")
        self.display = display
        self.screen = XDefaultScreenOfDisplay(display)
        debugPrint("Got screen: \(String(describing: screen))")
        self.rootWindow = Window(x11Window: screen.pointee.root, display: display)
        debugPrint("Got root window: \(String(describing: rootWindow.x11Window))")
        self.x11FileDescriptor = XConnectionNumber(display)
        debugPrint("X11 file descriptor: \(self.x11FileDescriptor)")
        
        self.x11WMDeleteWindowAtom = XInternAtom(display, "WM_DELETE_WINDOW".cString(using: .ascii), 0)
    }
    
    public func run() {
        debugPrint("Run")
        
        if (delegate == nil) {
            fatalError("Who forgot to specify app delegate? You've forgot to specify app delegate.")
        }
        
//        #if DEBUG
        addDebugRunLoopObserver()
//        #endif
        
        setupX()
        
        addSimpleWindow()
        addSimpleWindow()
        addSimpleWindow()
        addSimpleWindow()
        
        RunLoop.current.run()
    }
}
