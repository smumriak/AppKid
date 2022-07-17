//
//  LVImmutablePointer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: UnsafePointer<Value>) -> LVImmutablePointer<Struct, Value> {
    LVImmutablePointer(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: UnsafeMutablePointer<Value>) -> LVImmutablePointer<Struct, Value> {
    LVImmutablePointer(path, value)
}

public class LVImmutablePointer<Struct: InitializableWithNew, Value>: LVPath<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: UnsafePointer<Value>?

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: UnsafePointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: UnsafeMutablePointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer.map { UnsafePointer($0) }
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer
        return try super.withApplied(to: &result, tail: tail, body)
    }
}
