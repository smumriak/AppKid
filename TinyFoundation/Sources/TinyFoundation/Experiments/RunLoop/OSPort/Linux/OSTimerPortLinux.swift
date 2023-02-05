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

        func schedule(deadline: Int64) throws {
            var timespec = itimerspec()
            timespec.it_interval.tv_sec = 0
            timespec.it_interval.tv_nsec = 0

            timespec.it_value.tv_sec = Int(deadline / 1_000_000_000)
            timespec.it_value.tv_nsec = Int(deadline % 1_000_000_000)

            try syscall {
                timerfd_settime(handle /* ufd */,
                                CInt(TFD_TIMER_ABSTIME) /* flags */,
                                &timespec /* itimerspec */,
                                nil /* otmr */ )
            }
        }

        func cancel() throws {
            var timespec = itimerspec()
            timespec.it_interval.tv_sec = 0
            timespec.it_interval.tv_nsec = 0

            timespec.it_value.tv_sec = 0
            timespec.it_value.tv_nsec = 0

            try syscall {
                timerfd_settime(handle /* ufd */,
                                CInt(TFD_TIMER_ABSTIME) /* flags */,
                                &timespec /* itimerspec */,
                                nil /* otmr */ )
            }
        }
        
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
