//
//  LVSmartMutablePointersArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>), value: [SharedPointer<Value>]) -> LVSmartMutablePointersArray<Struct, Value> {
    LVSmartMutablePointersArray(paths.0, paths.1, value)
}

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>), value: [SharedPointerStorage<Value>]) -> LVSmartMutablePointersArray<Struct, Value> {
    LVSmartMutablePointersArray(paths.0, paths.1, value.smartPointers())
}

public struct LVSmartMutablePointersArray<Struct: InitializableWithNew, Value>: LVPath {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>

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
        return try value.optionalMutablePointers().withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try body(&result)
        }
    }
}
