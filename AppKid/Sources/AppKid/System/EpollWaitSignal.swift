//
//  EpollWaitSignal.swift
//  AppKid
//
//  Created by Serhii Mumriak on 19.08.2020.
//

import Foundation
import TinyFoundation

#if os(Linux)
import CEpoll
import Glibc
#else
public struct epoll_data {
    var ptr: UnsafeMutableRawPointer? = nil
    var fd: CInt = -1
    var u32: UInt32 = 0
    var u64: UInt64 = 0
}

public struct epoll_event {
    var events: UInt32 = 0
    var data: epoll_data = epoll_data()
}

fileprivate let EPOLL_CLOEXEC: CInt = 0
fileprivate let EFD_NONBLOCK: CInt = 0
fileprivate let EFD_CLOEXEC: CInt = 0
fileprivate let EPOLL_CTL_ADD: CInt = 1

fileprivate struct EPOLL_EVENTS: OptionSet {
    typealias RawValue = CUnsignedInt
    let rawValue: RawValue

    static let EPOLLIN = EPOLL_EVENTS(rawValue: 1 << 0)
    static let EPOLLET = EPOLL_EVENTS(rawValue: 1 << 31)
}

fileprivate let epoll_create1: (CInt) -> (CInt) = { _ in -1 }
fileprivate let eventfd: (CUnsignedInt, CInt) -> (CInt) = { _, _ in -1 }
fileprivate let epoll_ctl: (CInt, CInt, CInt, UnsafeMutablePointer<epoll_event>) -> (CInt) = {_, _, _, _ in -1}
fileprivate let epoll_wait: (CInt, UnsafeMutablePointer<epoll_event>, CInt, CInt) -> (CInt) = {_, _, _, _ in -1}
#endif

public class EpollWaitSignal {
    public fileprivate(set) var waitFileDescriptor: CInt = -1
    public fileprivate(set) var signalFileDescriptor: CInt = -1
    fileprivate var epollFileDescriptor: CInt = -1

    deinit {
        if signalFileDescriptor != -1 {
            close(signalFileDescriptor)
        }

        if epollFileDescriptor != -1 {
            close(epollFileDescriptor)
        }
    }

    public init() {}

    public init(waitFileDescriptor: CInt) throws {
        self.waitFileDescriptor = waitFileDescriptor

        epollFileDescriptor = epoll_create1(CInt(EPOLL_CLOEXEC))

        if epollFileDescriptor == -1 {
            throw POSIXErrorCode(rawValue: errno)!
        }

        signalFileDescriptor = eventfd(0, CInt(EFD_CLOEXEC) | CInt(EFD_NONBLOCK))

        if signalFileDescriptor == -1 {
            let error = POSIXErrorCode(rawValue: errno)!

            close(epollFileDescriptor)

            throw error
        }

        var event = epoll_event()
        let eventsMask: EPOLL_EVENTS = [EPOLL_EVENTS.EPOLLIN, EPOLL_EVENTS.EPOLLET]
        event.events = eventsMask.rawValue
        event.data.fd = waitFileDescriptor

        guard epoll_ctl(epollFileDescriptor, EPOLL_CTL_ADD, waitFileDescriptor, &event) == 0 else {
            let error = POSIXErrorCode(rawValue: errno)!

            close(signalFileDescriptor)
            close(epollFileDescriptor)

            throw error
        }
    }

    public func wait(timeout: CInt = -1) -> (awokenEvent: epoll_event, result: CInt) {
        var awokenEvent = epoll_event()
        let result = epoll_wait(epollFileDescriptor, &awokenEvent, 1, timeout)
        return (awokenEvent, result)
    }

    public func signal(value: UInt64 = 1) {
        var value = value
        write(signalFileDescriptor, &value, 8)
    }
}
