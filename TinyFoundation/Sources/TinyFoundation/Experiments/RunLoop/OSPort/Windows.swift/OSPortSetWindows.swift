//
//  OSPortSet.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if os(Windows)
    public extension OSPortSet {
        struct Context {
            public var timeout: Duration = .milliseconds(-1)
            public init() {}
        }

        enum WakeUpResult {
            case timeout
            case awokenPort(any OSPortProtocol)
            case windowsEvent
            case abandonedMutex(any OSPortProtocol)
            case inputOutputCompletion // whatever WAIT_IO_COMPLETION is used for
        }

        mutating func addPort(_ port: some OSPortProtocol) throws {
            ports[port.handle] = port
        }
        
        mutating func removePort(_ port: some OSPortProtocol) throws {
            ports[port.handle] = nil
        }

        func containsPort(_ port: some OSPortProtocol) -> Bool {
            ports[port.handle] != nil
        }

        init() throws {}

        func free() throws {}

        func waitForWakeUp(context: Context = Context()) throws -> WakeUpResult {
            ports.values.map { $0.handle }.withUnsafeBufferPointer { handles in
                let result = MsgWaitForMultipleObjectsEx
            }
            return .timeout
        }

        func acknowledgeWakeUp(context: Context = Context()) throws {
        }
    }
#endif
