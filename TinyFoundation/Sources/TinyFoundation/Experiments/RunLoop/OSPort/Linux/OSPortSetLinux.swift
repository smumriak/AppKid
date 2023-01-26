//
//  OSPortSet.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if os(Linux) || os(Android) || os(OpenBSD)
    import LinuxSys
    import Glibc

    public extension OSPortSet {
        struct Context {
            public var timeout: Duration = .milliseconds(-1)
            public init() {}
        }

        enum WakeUpResult {
            case timeout
            case awokenPort(any OSPortProtocol)
        }

        mutating func addPort(_ port: some OSPortProtocol) throws {
            let portHandle = port.handle
            ports[portHandle] = port

            let events: EPOLL_EVENTS = [.EPOLLONESHOT, .EPOLLET]
            let data = epoll_data_t(fd: portHandle)
            var event = epoll_event(events: events.rawValue, data: data)

            let result = epoll_ctl(handle /* epfd */,
                                   EPOLL_CTL_ADD /* op */,
                                   portHandle /* fd */,
                                   &event /* event */ )

            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: break
            }
        }

        mutating func removePort(_ port: some OSPortProtocol) throws {
            let portHandle = port.handle
            ports[portHandle] = nil

            let result = epoll_ctl(handle /* epfd */,
                                   EPOLL_CTL_DEL /* op */,
                                   portHandle /* fd */,
                                   nil /* event */ )

            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: break
            }
        }

        func containsPort(_ port: some OSPortProtocol) -> Bool {
            ports[port.handle] != nil
        }

        // throws POSIXErrorCode with possible values from [.EINVAL, .EMFILE, .ENFILE, .ENOMEM]
        init() throws {
            let result = epoll_create1(CInt(EPOLL_CLOEXEC))
            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: handle = result
            }
        }

        // throws POSIXErrorCode with possible values from [.EBADF, .EINTR, .EIO, .ENOSPC, .EDQUOT]
        func free() throws {
            let result = close(handle)
            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: break
            }
        }

        // throws POSIXErrorCode with possible values from [.EBADF, .EFAULT, .EINTR, .EINVAL]
        func wait(context: Context = Context()) throws -> WakeUpResult {
            var event = epoll_event()
            let result = epoll_wait(handle /* epfd */,
                                    &event /* events */,
                                    1, /* maxevents */
                                    CInt(context.timeout.milliseconds) /* timeout */ )
            switch result {
                case -1:
                    throw POSIXErrorCode(rawValue: errno)!

                case 0:
                    return .timeout

                case 1:
                    return .awokenPort(ports[event.data.fd]!)

                default:
                    fatalError("epoll_wait more than one signaled file descriptor. This should not happen and indicates and error in kernel")
            }
        }

        func acknowledge(context: Context = Context()) throws {
            // intentionally does nothing
        }
    }
#endif
