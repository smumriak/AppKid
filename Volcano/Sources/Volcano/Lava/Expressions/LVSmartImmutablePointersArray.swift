//
//  LVSmartImmutablePointersArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public func <- <Struct: InitializableWithNew>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafePointer<CChar>?>?>), value: [String]) -> LVSmartImmutablePointersArray<Struct, CChar> {
    LVSmartImmutablePointersArray(paths.0, paths.1, value.cStrings)
}

@inlinable @_transparent
public func <- <Struct: InitializableWithNew>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafePointer<CChar>?>?>), value: [SharedPointer<CChar>]) -> LVSmartImmutablePointersArray<Struct, CChar> {
    LVSmartImmutablePointersArray(paths.0, paths.1, value)
}

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafePointer<Value>?>?>), value: [SharedPointer<Value>]) -> LVSmartImmutablePointersArray<Struct, Value> {
    LVSmartImmutablePointersArray(paths.0, paths.1, value)
}

public struct LVSmartImmutablePointersArray<Struct: InitializableWithNew, Value>: LVPath {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<UnsafePointer<Value>?>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: [SharedPointer<Value>]
        
    @inlinable @_transparent
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ value: [SharedPointer<Value>]) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.value = value
    }
    
    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        return try value.optionalPointers().withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try body(&result)
        }
    }
}
