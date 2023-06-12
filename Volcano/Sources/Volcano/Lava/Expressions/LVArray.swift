//
//  LVArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022.
//

import TinyFoundation

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), value: [Value]) -> LVArray<Struct, Value> {
    LVArray(paths.0, paths.1, value)
}

public struct LVArray<Struct: InitializableWithNew, Value>: LVPath {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: [Value]
    
    @inlinable @_transparent
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ value: [Value]) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        return try value.withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try body(&result)
        }
    }
}
