//
//  RunLoop.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 03.07.2022.
//

import Foundation

#if os(Linux) || os(Android) || os(OpenBSD)
//    import Glibc or something
#elseif os(Windows)
//    import whatever
#elseif os(macOS)
    import Darwin
#endif

open class RunLoop1 {
    @Synchronized @_spi(AppKid) public static var runLoops: [ObjectIdentifier: RunLoop1] = [:]

    @_spi(AppKid) public unowned var thread: Thread = .current
    // @_spi(AppKid) public var items: [] = []
    @_spi(AppKid) public var modes: [RunLoop1.Mode: RunLoopMode] = [:]
    @_spi(AppKid) public var commonModes: [RunLoop1.Mode: RunLoopMode] = [:]

    @_spi(AppKid) public init(thread: Thread) {
        self.thread = thread
    }

    internal let lock = RecursiveLock()

    @_spi(AppKid) public func isFinished(in mode: RunLoopMode) -> Bool {
        return lock.synchronized {
            return mode.lock.synchronized {
                return false
            }
        }
    }

    open class var current: RunLoop1 {
        return getRunLoop(.current)
    }

    open class var main: RunLoop1 {
        return getRunLoop(.main)
    }

    private static func getRunLoop(_ thread: Thread) -> RunLoop1 {
        let identifier = ObjectIdentifier(thread)
        if let result = runLoops[identifier] {
            return result
        }

        return _runLoops.synchronized {
            let result = RunLoop1(thread: thread)

            runLoops[identifier] = result

            thread.deinitHook = {
                RunLoop1.runLoops[identifier] = nil
            }

            return result
        }
    }

    @discardableResult
    internal func run(in mode: RunLoopMode, duration: TimeInterval, returnAfterHandled: Bool) -> RunResult {
        return .handledSource
    }

    public func run(mode modeName: RunLoop1.Mode, before limitDate: Date) -> Bool {
        guard let mode = modes[modeName] else {
            return false
        }

        if isFinished(in: mode) {
            return false
        }

        let duration = limitDate.timeIntervalSince(Date())
        run(in: mode, duration: duration, returnAfterHandled: true)
        return false
    }
}

public extension RunLoop1 {
    struct Mode: RawRepresentable, Equatable, Hashable {
        public typealias RawValue = String
        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static let `default` = RunLoop1.Mode("RunLoop.Mode.Default")
        public static let common = RunLoop1.Mode("RunLoop.Mode.Common")
    }

    class Source {
    }

    enum RunResult: Int32 {
        case finished
        case stopped
        case timedOut
        case handledSource
    }
}

public protocol RunLoopItem {}

@_spi(AppKid) public class RunLoopMode: Hashable {
    internal let lock = RecursiveLock()

    internal var isEmpty: Bool {
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: RunLoopMode, rhs: RunLoopMode) -> Bool {
        return lhs === rhs
    }
}

@_spi(AppKid) public protocol OSPortProtocol: Hashable {
    #if os(Linux) || os(Android) || os(OpenBSD)
        typealias HandleType = CInt
    #elseif os(Windows)
        typealias HandleType = HANDLE
    #elseif os(macOS)
        typealias HandleType = mach_port_t
    #endif

    var handle: HandleType { get }
    func poll() throws -> OSPort
}

@_spi(AppKid) public extension OSPortProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.handle == rhs.handle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(handle)
    }
}

@_spi(AppKid) public struct OSPortSet: OSPortProtocol {
    public let handle: HandleType

    public func poll() throws -> OSPort {
        fatalError()
    }
}

@_spi(AppKid) public struct OSPort: OSPortProtocol {
    public let handle: HandleType

    public func poll() throws -> OSPort {
        return self
    }
}

#if os(Linux) || os(Android) || os(OpenBSD)
    @_spi(AppKid) extension OSPort {
        func acknowledgeWakeUp() throws {
        }
    }
#endif

#if os(Windows)
    @_spi(AppKid) extension OSPort {
        func acknowledgeWakeUp() throws {
        }
    }
#endif

private let kDeinitHook: AnyHashable = kDeinitHook

@_spi(AppKid) extension Thread {
    class DeinitHook {
        public typealias Callback = () -> ()

        let callback: Callback

        deinit {
            callback()
        }

        public init(_ callback: @escaping Callback) {
            self.callback = callback
        }
    }

    var deinitHook: DeinitHook.Callback? {
        get {
            return (threadDictionary[kDeinitHook] as? DeinitHook)?.callback
        }
        set {
            if let newValue = newValue {
                threadDictionary[kDeinitHook] = DeinitHook(newValue)
            }
        }
    }
}
