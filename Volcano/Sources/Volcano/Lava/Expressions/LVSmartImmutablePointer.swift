//
//  LVSmartImmutablePointer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: SharedPointer<Value>) -> LVSmartImmutablePointer<Struct, Value> {
    LVSmartImmutablePointer(path, value)
}

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: SharedPointerStorage<Value>) -> LVSmartImmutablePointer<Struct, Value> {
    LVSmartImmutablePointer(path, value.handle)
}

public struct LVSmartImmutablePointer<Struct: InitializableWithNew, Value>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: SharedPointer<Value>?

    @inlinable @_transparent
    public init(_ valueKeyPath: ValueKeyPath, _ pointer: SharedPointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer.map { UnsafePointer($0.pointer) }
        return try body(&result)
    }
}
