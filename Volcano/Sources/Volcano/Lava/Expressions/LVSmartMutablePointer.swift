//
//  LVSmartMutablePointer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>, value: SharedPointer<Value>) -> LVSmartMutablePointer<Struct, Value> {
    LVSmartMutablePointer(path, value)
}

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>, value: SharedPointerStorage<Value>) -> LVSmartMutablePointer<Struct, Value> {
    LVSmartMutablePointer(path, value.handle)
}

public struct LVSmartMutablePointer<Struct: InitializableWithNew, Value>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>

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
        result[keyPath: valueKeyPath] = pointer?.pointer
        return try body(&result)
    }
}
