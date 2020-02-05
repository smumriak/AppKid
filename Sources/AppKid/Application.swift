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
    internal lazy var x11PollThread = Thread { self.pollForX11Events() }
    
    #if os(Linux)
    internal var x11EpollFileDecriptor: Int32 = -1
    internal let x11EventFileDescriptor = CEpoll.eventfd(0, Int32(CEpoll.EFD_CLOEXEC) | Int32(CEpoll.EFD_NONBLOCK))
    #endif
    
    internal init () {
        guard let display = XOpenDisplay(nil) else {
            fatalError("Could not open X display.")
        }
        
        self.display = display
        self.screen = XDefaultScreenOfDisplay(display)
        self.rootWindow = Window(x11Window: screen.pointee.root, display: display)
        self.x11FileDescriptor = XConnectionNumber(display)
        self.x11WMDeleteWindowAtom = XInternAtom(display, "WM_DELETE_WINDOW".cString(using: .ascii), 0)
    }
    
    public func run() {
        if (delegate == nil) {
            fatalError("Who forgot to specify app delegate? You've forgot to specify app delegate.")
        }
        
        #if DEBUG
//        addDebugRunLoopObserver()
        #endif
        
        setupX()
        
        addSimpleWindow()
        
        RunLoop.current.run()
    }
}
