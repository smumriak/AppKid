//
//  SwiftGMainLoopRunLoopSource.swift
//  SwfitGlib
//
//  Created by Serhii Mumriak on 20.11.2021.
//

import Foundation
import CGlib
import TinyFoundation

// public class SwiftGMainLoop {
//     public let context: SwiftGMainContext

//     deinit {
//         context.releaseOwnership()
//     }

//     public init?(context: SwiftGMainContext) {
//         self.context = context

//         context.acquireOwnership()
//     }

//     internal lazy var runLoopSource = SwiftGMainLoopRunLoopSource(context: context)

//     public func schedule(in runLoop: RunLoop, forMode mode: RunLoop.Mode) {
//         runLoopSource.schedule(in: runLoop, forMode: mode)
//     }

//     public func remove(from runLoop: RunLoop, forMode mode: RunLoop.Mode) {
//         runLoopSource.remove(from: runLoop, forMode: mode)
//     }

//     public func invalidate() {
//         runLoopSource.invalidate()
//     }
// }

internal class SwiftGMainLoopRunLoopSource {
    private let context: SwiftGMainContext
    private let epollFileDescriptorPort: FileDescriptorPort
    private var observedGlibFileDescriptors: [GPollFD] = []

    internal init(context: SwiftGMainContext) {
        let epollFd = epoll_create1(Int32(EPOLL_CLOEXEC))

        guard epollFd != -1,
              let epollFileDescriptorPort = FileDescriptorPort(fileDescriptor: epollFd, closeOnInvalidate: true) else {
            fatalError("Can not create new epoll file descriptor, system is broken and further execution is not possible")
        }

        self.context = context

        self.epollFileDescriptorPort = epollFileDescriptorPort
        epollFileDescriptorPort.enableNotificationType([.read])

        epollFileDescriptorPort.setDelegate(self)

        _ = context.prepare()
        observedGlibFileDescriptors = context.updateFileDescriptorsToObserve()

        observedGlibFileDescriptors.forEach {
            var addEpollEvent = $0.epollEvent
            _ = epoll_ctl(epollFileDescriptorPort.fileDescriptor, EPOLL_CTL_ADD, $0.fd, &addEpollEvent)
        }
    }

    internal func schedule(in runLoop: RunLoop, forMode mode: RunLoop.Mode) {
        epollFileDescriptorPort.schedule(in: runLoop, forMode: mode)
    }

    public func remove(from runLoop: RunLoop, forMode mode: RunLoop.Mode) {
        epollFileDescriptorPort.remove(from: runLoop, forMode: mode)
    }

    internal func invalidate() {
        epollFileDescriptorPort.invalidate()
    }

    internal func stopObservingKnownDescriptors() {
        var deleteEpollEvent = epoll_event()
        observedGlibFileDescriptors.forEach {
            deleteEpollEvent.data.fd = $0.fd
            _ = epoll_ctl(epollFileDescriptorPort.fileDescriptor, EPOLL_CTL_DEL, $0.fd, &deleteEpollEvent)
        }
    }

    internal func refreshKnownDescriptors() {
        _ = context.prepare()

        observedGlibFileDescriptors = context.updateFileDescriptorsToObserve()
    }

    internal func startObservingKnownDescriptors() {
        observedGlibFileDescriptors.forEach {
            var addEpollEvent = $0.epollEvent
            _ = epoll_ctl(epollFileDescriptorPort.fileDescriptor, EPOLL_CTL_ADD, $0.fd, &addEpollEvent)
        }
    }
}

extension SwiftGMainLoopRunLoopSource: FileDescriptorPortDelegate {
    func handle(_ message: PortMessage) {}

    func handle(awokenFileDescriptorPort: FileDescriptorPort) {
        // 2. perform g_main_context_check with known file descriptors
        if context.needsToDispatchEvents {
            // 1. remove all previously known file descriptors from epoll file descriptor via epoll_ctl + EPOLL_CTL_DEL
            stopObservingKnownDescriptors()

            // 3. if check returned true perform g_main_context_dispatch
            context.dispatchEvents()

            // 4. prepare glib poll shit via g_main_context_prepare
            // 5. query new set of file descriptors to poll
            refreshKnownDescriptors()

            // 6. add this set of file descriptors to epoll file descriptor via epoll_ctl + EPOLL_CTL_ADD
            startObservingKnownDescriptors()

            // 7. enable read notification on awoken file descriptor
            awokenFileDescriptorPort.enableNotificationType([.read])
        }
    }
}

internal extension GPollFD {
    var epollEvent: epoll_event {
        var result = epoll_event()

        result.data.fd = fd
        result.events = GIOCondition(rawValue: UInt32(events)).epollEvents.rawValue

        return result
    }
}

internal extension GIOCondition {
    var epollEvents: EPOLL_EVENTS {
        var result: EPOLL_EVENTS = []

        if (self.rawValue & G_IO_IN.rawValue) != 0 {
            result.formUnion(.EPOLLIN)
        }

        if (self.rawValue & G_IO_OUT.rawValue) != 0 {
            result.formUnion(.EPOLLOUT)
        }

        if (self.rawValue & G_IO_PRI.rawValue) != 0 {
            result.formUnion(.EPOLLPRI)
        }

        if (self.rawValue & G_IO_ERR.rawValue) != 0 {
            result.formUnion(.EPOLLERR)
        }

        if (self.rawValue & G_IO_HUP.rawValue) != 0 {
            result.formUnion(.EPOLLHUP)
        }

        result.formUnion([.EPOLLONESHOT, .EPOLLET])

        return result
    }
}
