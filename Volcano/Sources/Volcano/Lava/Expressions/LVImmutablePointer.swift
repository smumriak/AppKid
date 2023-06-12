//
//  LVImmutablePointer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: UnsafePointer<Value>) -> LVImmutablePointer<Struct, Value> {
    LVImmutablePointer(path, value)
}

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: UnsafeMutablePointer<Value>) -> LVImmutablePointer<Struct, Value> {
    LVImmutablePointer(path, value)
}

public struct LVImmutablePointer<Struct: InitializableWithNew, Value>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: UnsafePointer<Value>?

    @inlinable @_transparent
    public init(_ valueKeyPath: ValueKeyPath, _ pointer: UnsafePointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: UnsafeMutablePointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer.map { UnsafePointer($0) }
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer
        return try body(&result)
    }
}
