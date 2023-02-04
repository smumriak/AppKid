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
            public var timeout: Duration? = nil
            public init() {}
        }

        enum WakeUpResult {
            case timeout
            case awokenPort(any OSPortProtocol)
        }

        mutating func addPort(_ port: some OSPortProtocol) throws {
            let portHandle = port.handle
            ports[portHandle] = port

            let events: EPOLL_EVENTS = [.EPOLLIN, .EPOLLET]
            let data = epoll_data_t(fd: portHandle)
            var event = epoll_event(events: events.rawValue, data: data)

            do {
                try syscall {
                    epoll_ctl(handle /* epfd */,
                              EPOLL_CTL_ADD /* op */,
                              portHandle /* fd */,
                              &event /* event */ )
                }
            } catch POSIXErrorCode.EEXIST {
                // NO-OP
            }
        }

        mutating func removePort(_ port: some OSPortProtocol) throws {
            let portHandle = port.handle
            ports[portHandle] = nil

            do {
                try syscall {
                    epoll_ctl(handle /* epfd */,
                              EPOLL_CTL_DEL /* op */,
                              portHandle /* fd */,
                              nil /* event */ )
                }
            } catch POSIXErrorCode.ENOENT {
                // NO-OP
            }
        }

        // throws POSIXErrorCode with possible values from [.EINVAL, .EMFILE, .ENFILE, .ENOMEM]
        init() throws {
            try handle = syscall {
                epoll_create1(CInt(EPOLL_CLOEXEC))
            }
        }

        // throws POSIXErrorCode with possible values from [.EBADF, .EIO, .ENOSPC, .EDQUOT]
        func free() throws {
            try syscall {
                close(handle)
            }
        }

        // throws POSIXErrorCode with possible values from [.EBADF, .EFAULT, .EINVAL]
        func wait(context: Context = Context()) throws -> WakeUpResult {
            var event = epoll_event()
            let result = try syscall {
                epoll_wait(handle /* epfd */,
                           &event /* events */,
                           1, /* maxevents */
                           CInt(context.timeout?.milliseconds ?? -1) /* timeout */ )
            }
            switch result {
                case 0:
                    return .timeout

                case 1:
                    return .awokenPort(ports[event.data.fd]!)

                default:
                    fatalError("epoll_wait returned more than one signaled file descriptor. This should not happen and indicates and error in kernel")
            }
        }
    }
#endif
