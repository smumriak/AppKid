//
//  OSTimerPortLinux.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.01.2023
//

#if os(Windows)
    import Glibc
    import LinuxSys

    @_spi(AppKid)
    public extension OSTimerPort {
        struct Context {
            public var timeout: Duration = .milliseconds(-1)
            public init() {}
        }

        enum WakeUpResult {
            case timeout
            case awokenPort(OSTimerPort)
        }
        
        init() throws {
            let result = timerfd_create(0, CInt(EFD_CLOEXEC | EFD_NONBLOCK))
            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: handle = result
            }
            shouldFree = true
        }

        func free() throws {
            guard shouldFree else { return }
            let result = close(handle)
            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: break
            }
        }
        
        func wait(context: Context = Context()) throws -> WakeUpResult {
            // var info = pollfd(fd: handle, events: Int16(POLLIN), revents: 0)

            return .awokenPort(self)
        }

        func signal(context: Context) throws {
            fatalError("Unimplemented")
        }

        func acknowledge(context: Context = Context()) throws {
            var ret: CInt = 0
            repeat {
                ret = eventfd_write(handle, 1)
            } while ret == -1 && errno == EINTR
        }
    }

#endif
