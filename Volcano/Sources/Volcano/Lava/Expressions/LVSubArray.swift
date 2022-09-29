//
//  LVSubArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<SubStruct>?>), builder: LavaBuilderArray<SubStruct>) -> LVSubArray<Struct, SubStruct> {
    LVSubArray(paths.0, paths.1, builder)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<SubStruct>?>), @LavaBuilderArray<SubStruct> content: () -> (LavaBuilderArray<SubStruct>)) -> LVSubArray<Struct, SubStruct> {
    LVSubArray(paths.0, paths.1, content())
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), value: [LavaBuilder<Value>?]) -> LVSubArray<Struct, Value> {
    LVSubArray(paths.0, paths.1, LavaBuilderArray(value.compactMap { $0 }))
}

public struct LVSubArray<Struct: VulkanStructure, SubStruct: VulkanStructure>: LVPath {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<SubStruct>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let builder: LavaBuilderArray<SubStruct>

    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ builder: LavaBuilderArray<SubStruct>) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.builder = builder
    }

    @inlinable @inline(__always)
    public func withApplied<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try builder.withUnsafeResultPointer {
            result[keyPath: countKeyPath] = CUnsignedInt($0.count)
            result[keyPath: valueKeyPath] = $0.baseAddress!

            return try withAppliedDefault(to: &result, tail: tail, body)
        }
    }
}
