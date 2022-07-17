//
//  LVSmartMutablePointersArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>), value: [SmartPointer<Value>]) -> LVSmartMutablePointersArray<Struct, Value> {
    LVSmartMutablePointersArray(paths.0, paths.1, value)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>), value: [HandleStorage<SmartPointer<Value>>]) -> LVSmartMutablePointersArray<Struct, Value> {
    LVSmartMutablePointersArray(paths.0, paths.1, value.smartPointers())
}

public class LVSmartMutablePointersArray<Struct: InitializableWithNew, Value>: LVPath<Struct> {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: [SmartPointer<Value>]
        
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ value: [SmartPointer<Value>]) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.value = value
    }
    
    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.optionalMutablePointers().withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}
