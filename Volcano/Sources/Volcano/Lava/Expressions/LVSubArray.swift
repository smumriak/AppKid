//
//  LVSubArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<SubStruct>?>), builder: LavaContainerArray<SubStruct>) -> LVSubArray<Struct, SubStruct> {
    LVSubArray(paths.0, paths.1, builder)
}

@inlinable @_transparent
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<SubStruct>?>), @LavaBuilderArray<SubStruct> content: () -> (LavaContainerArray<SubStruct>)) -> LVSubArray<Struct, SubStruct> {
    LVSubArray(paths.0, paths.1, content())
}

@inlinable @_transparent
public func <- <Struct: VulkanStructure, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), value: [LavaContainer<Value>?]) -> LVSubArray<Struct, Value> {
    LVSubArray(paths.0, paths.1, LavaContainerArray(value.compactMap { $0 }))
}

public struct LVSubArray<Struct: VulkanStructure, SubStruct: VulkanStructure>: LVPath {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<SubStruct>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let builder: LavaContainerArray<SubStruct>

    @inlinable @_transparent
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ builder: LavaContainerArray<SubStruct>) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.builder = builder
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        return try builder.withUnsafeResultPointer {
            result[keyPath: countKeyPath] = CUnsignedInt($0.count)
            result[keyPath: valueKeyPath] = $0.baseAddress!

            return try body(&result)
        }
    }
}
