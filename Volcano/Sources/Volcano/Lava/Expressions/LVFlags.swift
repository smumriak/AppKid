//
//  LVFlags.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value: RawRepresentable>(path: WritableKeyPath<Struct, Value.RawValue>, value: Value) -> LVFlags<Struct, Value> where Value.RawValue == VkFlags {
    LVFlags(path, value)
}

public struct LVFlags<Struct: InitializableWithNew, Value: RawRepresentable>: LVPath where Value.RawValue == VkFlags {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, Value.RawValue>

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
        result[keyPath: valueKeyPath] = value.rawValue
        return try body(&result)
    }
}
