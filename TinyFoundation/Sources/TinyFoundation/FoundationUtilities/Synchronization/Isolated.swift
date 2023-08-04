//
//  Isolated.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 03.08.2023
//

@dynamicMemberLookup
public struct Isolated<Value> {
    @usableFromInline
    internal var _value: Value

    @usableFromInline
    internal let lock = RecursiveLock()

    public init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
        self._value = try value()
    }

    public subscript<T: Sendable>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        isolated {
            _value[keyPath: keyPath]
        }
    }

    public subscript<T: Sendable>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get {
            isolated {
                _value[keyPath: keyPath]
            }
        }
        mutating set {
            isolated {
                _value[keyPath: keyPath] = newValue
            }
        }
    }

    @_transparent
    public func isolated<T: Sendable>(_ body: () throws -> T) rethrows -> T {
        try lock.synchronized(body)
    }

    @_transparent
    public func isolated<T: Sendable>(_ body: (_ value: Value) throws -> T) rethrows -> T {
        try lock.synchronized {
            try body(_value)
        }
    }

    @_transparent
    public mutating func mutatingIsolated<T: Sendable>(_ body: (_ value: inout Value) throws -> T) rethrows -> T {
        try lock.synchronized {
            try body(&_value)
        }
    }

    @_transparent
    public mutating func replace(with newValue: @autoclosure @Sendable () throws -> Value) {
        isolated {
            _value = try newValue()
        }
    }
}

public extension Isolated where Value: Sendable {
    var value: Value {
        get {
            isolated {
                _value
            }
        }
        set {
            isolated {
                _value = newValue
            }
        }
    }
}

extension Isolated: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
    }
}

extension Isolated: Equatable where Value: Equatable {
    public static func == (lhs: Isolated, rhs: Isolated) -> Bool {
        lhs.isolated { lhsValue in
            rhs.isolated { rhsValue in
                lhsValue == rhsValue
            }
        }
    }
}
