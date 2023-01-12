//
//  LVNilValueArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022.
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value, Count: BinaryInteger>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), count: Count) -> LVNilValueArray<Struct, Value, Count> {
    LVNilValueArray(paths.0, paths.1, count)
}

public struct LVNilValueArray<Struct: InitializableWithNew, Value, Count: BinaryInteger>: LVPath {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let count: Count

    @inlinable @_transparent
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ count: Count) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.count = count
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        result[keyPath: countKeyPath] = CUnsignedInt(count)
        result[keyPath: valueKeyPath] = nil
        return try body(&result)
    }
}
