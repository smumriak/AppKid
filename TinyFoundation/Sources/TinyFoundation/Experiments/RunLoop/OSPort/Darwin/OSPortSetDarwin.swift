//
//  OSPortSet.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import Darwin

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
            fatalError("Unimplemented")
        }

        mutating func removePort(_ port: some OSPortProtocol) throws {
            fatalError("Unimplemented")
        }

        func containsPort(_ port: some OSPortProtocol) -> Bool {
            ports[port.handle] != nil
        }

        init() throws {
            fatalError("Unimplemented")
        }

        func free() throws {
            fatalError("Unimplemented")
        }

        func wait(context: Context = Context()) throws -> WakeUpResult {
            fatalError("Unimplemented")
        }

        func signal(context: Context) throws {
            fatalError("Unimplemented")
        }

        func acknowledge(context: Context = Context()) throws {
            fatalError("Unimplemented")
        }
    }
#endif
