//
//  LVFlags64.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: RawRepresentable>(path: WritableKeyPath<Struct, Value.RawValue>, value: Value) -> LVFlags64<Struct, Value> where Value.RawValue == VkFlags64 {
    LVFlags64(path, value)
}

public class LVFlags64<Struct: InitializableWithNew, Value: RawRepresentable>: LVPath<Struct> where Value.RawValue == VkFlags64 {
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
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = value.rawValue
        return try super.withApplied(to: &result, tail: tail, body)
    }
}
