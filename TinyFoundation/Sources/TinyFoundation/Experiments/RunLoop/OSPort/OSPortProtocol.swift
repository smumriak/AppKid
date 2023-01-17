//
//  OSPortProtocol.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

import HijackingHacks

public protocol OSPortProtocol: Hashable {
    associatedtype Context
    associatedtype WakeUpResult
    #if os(Linux) || os(Android) || os(OpenBSD)
        typealias HandleType = CInt
    #elseif os(Windows)
        typealias HandleType = HANDLE
    #elseif os(macOS)
        typealias HandleType = mach_port_t
    #endif

    var handle: HandleType { get }
    func waitForWakeUp(context: Context) throws -> WakeUpResult
    func acknowledgeWakeUp(context: Context) throws
    init() throws
    func free() throws
}

public extension OSPortProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.handle == rhs.handle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(handle)
    }

    @_transparent
    func isEqual(to other: some OSPortProtocol) -> Bool {
        handle == other.handle
    }

    @_transparent
    func isEqual(to other: (some OSPortProtocol)?) -> Bool {
        other?.handle == handle
    }
}

public struct OSPort: OSPortProtocol {
    public let handle: HandleType
    public let shouldFree: Bool

    static var dispatchMainQueuePort: OSPort {
        return OSPort(_dispatch_get_main_queue_port_4CF(), shouldFree: false)
    }
}

public struct OSPortSet: OSPortProtocol {
    public let handle: HandleType
    public internal(set) var ports: [OSPort.HandleType: any OSPortProtocol] = [:]
}

internal extension Duration {
    var milliseconds: Int64 {
        let components = components
        return components.seconds * 1000 + Int64(Double(components.attoseconds) * 0.000_000_000_000_001)
    }
}
