//
//  RunLoopMode.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 14.01.2023
//

@_spi(AppKid)
public class RunLoopMode: Hashable {
    public let name: RunLoop1.Mode
    internal let lock = RecursiveLock()
    internal var portSet: OSPortSet
    internal var timerPort: OSPort
    public internal(set) var activity: RunLoop1.Activity = []

    deinit {
        try? portSet.free()
    }
    
    public init(name: RunLoop1.Mode) {
        self.name = name
        do {
            try portSet = OSPortSet()
            try timerPort = OSPort.timerPort()
            try portSet.addPort(timerPort)
        } catch {
            fatalError("Sorry, RunLoop experienced an error while trying to allocate native OS port set: \(error.localizedDescription)")
        }
    }

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
}
