//
//  LVSmartMutablePointer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>, value: SmartPointer<Value>) -> LVSmartMutablePointer<Struct, Value> {
    LVSmartMutablePointer(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>, value: HandleStorage<SmartPointer<Value>>) -> LVSmartMutablePointer<Struct, Value> {
    LVSmartMutablePointer(path, value.handlePointer)
}

public class LVSmartMutablePointer<Struct: InitializableWithNew, Value>: LVPath<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: SmartPointer<Value>?

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: SmartPointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer?.pointer
        return try super.withApplied(to: &result, tail: tail, body)
    }
}
