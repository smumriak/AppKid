//
//  LVSmartImmutablePointer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: SharedPointer<Value>) -> LVSmartImmutablePointer<Struct, Value> {
    LVSmartImmutablePointer(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: HandleStorage<SharedPointer<Value>>) -> LVSmartImmutablePointer<Struct, Value> {
    LVSmartImmutablePointer(path, value.handlePointer)
}

public class LVSmartImmutablePointer<Struct: InitializableWithNew, Value>: LVPath<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: SharedPointer<Value>?

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: SharedPointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer.map { UnsafePointer($0.pointer) }
        return try super.withApplied(to: &result, tail: tail, body)
    }
}
