//
//  LVImmutablePointerToValue.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: Value) -> LVImmutablePointerToValue<Struct, Value> {
    LVImmutablePointerToValue(path, value)
}

public struct LVImmutablePointerToValue<Struct: InitializableWithNew, Value>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Value

    @inlinable @_transparent
    public init(_ valueKeyPath: ValueKeyPath, _ value: Value) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        return try withUnsafePointer(to: value) {
            result[keyPath: valueKeyPath] = $0
            return try body(&result)
        }
    }
}
