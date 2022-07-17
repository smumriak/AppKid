//
//  LVArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022.
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), value: [Value]) -> LVArray<Struct, Value> {
    LVArray(paths.0, paths.1, value)
}

public class LVArray<Struct: InitializableWithNew, Value>: LVPath<Struct> {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: [Value]
        
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ value: [Value]) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}
