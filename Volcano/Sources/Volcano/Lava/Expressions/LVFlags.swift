//
//  LVFlags.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: RawRepresentable>(path: WritableKeyPath<Struct, Value.RawValue>, value: Value) -> LVFlags<Struct, Value> where Value.RawValue == VkFlags {
    LVFlags(path, value)
}

public struct LVFlags<Struct: InitializableWithNew, Value: RawRepresentable>: LVPath where Value.RawValue == VkFlags {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, Value.RawValue>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Value

    public init(_ valueKeyPath: ValueKeyPath, _ value: Value) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public func withApplied<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = value.rawValue
        return try withAppliedDefault(to: &result, tail: tail, body)
    }
}
