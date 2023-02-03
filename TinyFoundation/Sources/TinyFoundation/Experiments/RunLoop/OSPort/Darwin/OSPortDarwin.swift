//
//  OSPort.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import Darwin

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
            fatalError("Unimplemented")
        }

        init(_ handle: HandleType, shouldFree: Bool = false) {
            fatalError("Unimplemented")
        }

        static func timerPort() throws -> OSPort {
            fatalError("Unimplemented")
        }

        func free() throws {
            fatalError("Unimplemented")
        }
        
        func wait(context: Context = Context()) throws -> WakeUpResult {
            // var info = pollfd(fd: handle, events: Int16(POLLIN), revents: 0)

            return .awokenPort(self)
        }

        func signal(context: Context) throws {
            fatalError("Unimplemented")
        }

        func acknowledge(context: Context = Context()) throws {
            fatalError("Unimplemented")
        }
    }

#endif
