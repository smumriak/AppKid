//
//  OSPort.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if os(Linux) || os(Android) || os(OpenBSD)
    import Glibc
    import CLinuxSys

    @_spi(AppKid)
    public extension OSPort {
        struct Context {
            public var timeout: Duration = .milliseconds(-1)
            public init() {}
        }

        enum WakeUpResult {
            case timeout
            case awokenPort(OSPort)
        }
        
        init() throws {
            let result = eventfd(0, CInt(EFD_CLOEXEC | EFD_NONBLOCK))
            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: handle = result
            }
            shouldFree = true
        }

        init(_ handle: HandleType, shouldFree: Bool = false) {
            self.handle = handle
            self.shouldFree = shouldFree
        }

        static func timerPort() throws -> OSPort {
            let result = timerfd_create(CLOCK_MONOTONIC, CInt(TFD_NONBLOCK | TFD_CLOEXEC))
            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: break
            }
            return Self(result, shouldFree: true)
        }

        func free() throws {
            guard shouldFree else { return }
            let result = close(handle)
            switch result {
                case -1: throw POSIXErrorCode(rawValue: errno)!
                default: break
            }
        }
        
        func waitForWakeUp(context: Context = Context()) throws -> WakeUpResult {
            // var info = pollfd(fd: handle, events: Int16(POLLIN), revents: 0)

            return .awokenPort(self)
        }

        func acknowledgeWakeUp(context: Context = Context()) throws {
            var ret: CInt = 0
            repeat {
                ret = eventfd_write(handle, 1)
            } while ret == -1 && errno == EINTR
        }
    }

#endif
