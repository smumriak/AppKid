//
//  LVImmutablePointerToValue.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: Value) -> LVImmutablePointerToValue<Struct, Value> {
    LVImmutablePointerToValue(path, value)
}

public class LVImmutablePointerToValue<Struct: InitializableWithNew, Value>: LVPath<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Value

    public init(_ valueKeyPath: ValueKeyPath, _ value: Value) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try withUnsafePointer(to: value) {
            result[keyPath: valueKeyPath] = $0
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}
