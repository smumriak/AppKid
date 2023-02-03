//
//  OSPort.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if os(Linux) || os(Android) || os(OpenBSD)
    import Glibc
    import LinuxSys

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
            try handle = syscall {
                eventfd(0, CInt(EFD_CLOEXEC | EFD_NONBLOCK))
            }
            shouldFree = true
        }

        init(_ handle: HandleType, shouldFree: Bool = false) {
            self.handle = handle
            self.shouldFree = shouldFree
        }

        func free() throws {
            guard shouldFree else { return }
            try syscall {
                close(handle)
            }
        }
        
        func wait(context: Context = Context()) throws -> WakeUpResult {
            try poll(timeout: context.timeout)

            return .awokenPort(self)
        }

        func signal(context: Context = Context()) throws {
            try syscall {
                eventfd_write(handle /* fd */,
                              1 /* value */ )
            }
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

    internal extension Optional where Wrapped == timespec {
        @_transparent
        func withTimespec<R>(_ body: (UnsafePointer<Wrapped>?) throws -> (R)) rethrows -> R {
            switch self {
                case .none:
                    return try body(nil)

                case .some(var value):
                    return try withUnsafePointer(to: &value, body)
            }
        }
    }

    internal extension OSPortProtocol {
        @_transparent
        func poll(timeout: Duration? = nil) throws {
            var info = pollfd(fd: handle, events: Int16(POLLIN), revents: 0)
            var elapsed: UInt64 = 0
            var start: UInt64 = .absoluteTime

            try syscall {
                let timespec: timespec?
                
                if let timeout_ns = timeout?.nanoseconds, timeout_ns > 0 && elapsed < UInt64(timeout_ns) {
                    let delta = UInt64(timeout_ns) - elapsed
                    timespec = .init(tv_sec: Int(delta / 1000000000), tv_nsec: Int(delta % 1000000000))
                } else {
                    timespec = nil
                }

                let result: CInt = timespec.withTimespec { timespec in
                    ppoll(&info /* fds */,
                          1 /* nfds */,
                          timespec /* timeout */,
                          nil /* ss */ )
                }
                 
                if result == -1 && errno == EINTR {
                    let end: UInt64 = .absoluteTime
                    elapsed += end - start
                    start = end
                }

                return result
            }
        }
    }
#endif
