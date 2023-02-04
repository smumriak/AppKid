//
//  OSTimerPortLinux.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.01.2023
//

#if os(Linux) || os(Android) || os(OpenBSD)
    import Glibc
    import LinuxSys

    @_spi(AppKid)
    public extension OSTimerPort {
        struct Context {
            public var timeout: Duration? = nil
            public init() {}
        }

        enum WakeUpResult {
            case timeout
            case awokenPort(OSTimerPort)
        }
        
        init() throws {
            try handle = syscall {
                timerfd_create(0, CInt(EFD_CLOEXEC | EFD_NONBLOCK))
            }
            shouldFree = true
        }

        func free() throws {
            guard shouldFree else { return }
            try syscall {
                close(handle)
            }
        }

        func schedule() {}
        
        func wait(context: Context = Context()) throws -> WakeUpResult {
            try poll(timeout: context.timeout)

            return .awokenPort(self)
        }

        func acknowledge(context: Context = Context()) throws {
            // Now we acknowledge the wakeup. awokenFd is an eventfd (or possibly a
            // timerfd ?). In either case, we read an 8-byte integer, as per eventfd(2)
            // and timerfd_create(2).
            var value: UInt64 = 0
            let result = try syscall {
                read(handle /* fd */,
                     &value /* buf */,
                     MemoryLayout.size(ofValue: value) /* nbytes */ )
            }

            if result != MemoryLayout.size(ofValue: value) {
                throw POSIXErrorCode(rawValue: errno)!
            }
        }
    }

#endif
