//
//  LVBufferPointerWithoutCount.swift
//  Volcano
//
//  Created by Serhii Mumriak on 10.01.2023
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: UnsafeBufferPointer<Value>) -> LVBufferPointerWithoutCount<Struct, Value> {
    LVBufferPointerWithoutCount(path, value)
}

public struct LVBufferPointerWithoutCount<Struct: InitializableWithNew, Value>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: UnsafeBufferPointer<Value>
        
    @inlinable @_transparent
    public init(_ valueKeyPath: ValueKeyPath, _ value: UnsafeBufferPointer<Value>) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = value.baseAddress!
        return try body(&result)
    }
}
