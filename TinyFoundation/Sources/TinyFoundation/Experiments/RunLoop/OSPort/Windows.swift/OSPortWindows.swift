//
//  OSPort.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if os(Windows)
    @_spi(AppKid)
    public extension OSPort {
        struct Context {
            public var timeout: Duration = .milliseconds(-1)
            public init() {}
        }

        struct WakeUpResult {}

        static func timerPort() throws -> OSPort { fatalError() }
        
        func free() throws {}
        
        func waitForWakeUp(context: Context = Context()) throws -> WakeUpResult {
            return .awokenPort(self)
        }
    
        func acknowledgeWakeUp(context: Context = Context()) throws {
        }
    }
#endif
