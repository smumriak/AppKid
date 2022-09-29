//
//  LVValue.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022.
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, Value>, value: Value) -> LVValue<Struct, Value> {
    return LVValue(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew>(path: WritableKeyPath<Struct, VkBool32>, value: Bool) -> LVValue<Struct, VkBool32> {
    return LVValue(path, value.vkBool)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: BinaryInteger>(path: WritableKeyPath<Struct, CInt>, value: Value) -> LVValue<Struct, CInt> {
    LVValue(path, CInt(value))
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: BinaryInteger>(path: WritableKeyPath<Struct, CUnsignedInt>, value: Value) -> LVValue<Struct, CUnsignedInt> {
    LVValue(path, CUnsignedInt(value))
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: BinaryInteger>(path: WritableKeyPath<Struct, Int64>, value: Value) -> LVValue<Struct, Int64> {
    LVValue(path, Int64(value))
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: BinaryInteger>(path: WritableKeyPath<Struct, UInt64>, value: Value) -> LVValue<Struct, UInt64> {
    LVValue(path, UInt64(value))
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: BinaryFloatingPoint>(path: WritableKeyPath<Struct, Float>, value: Value) -> LVValue<Struct, Float> {
    LVValue(path, Float(value))
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: BinaryFloatingPoint>(path: WritableKeyPath<Struct, Double>, value: Value) -> LVValue<Struct, Double> {
    LVValue(path, Double(value))
}

public struct LVValue<Struct: InitializableWithNew, Value>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, Value>

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
        result[keyPath: valueKeyPath] = value
        return try withAppliedDefault(to: &result, tail: tail, body)
    }
}
