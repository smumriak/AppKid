//
//  LVNextChainStruct.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public prefix func <- <Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(builder: LavaContainer<NextStruct>) -> LVNextChainStruct<Struct, NextStruct> {
    LVNextChainStruct(builder)
}

@inlinable @_transparent
public prefix func <- <Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(@Lava<NextStruct> _ content: () throws -> LavaContainer<NextStruct>) rethrows -> LVNextChainStruct<Struct, NextStruct> {
    try LVNextChainStruct(content())
}

@inlinable @_transparent
public func next<Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(_: NextStruct.Type, @Lava<NextStruct> _ content: () throws -> LavaContainer<NextStruct>) rethrows -> LVNextChainStruct<Struct, NextStruct> {
    try LVNextChainStruct(content())
}

public struct LVNextChainStruct<Struct: VulkanChainableStructure, Next: VulkanChainableStructure>: LVPath {
    @usableFromInline
    internal let builder: LavaContainer<Next>

    @inlinable @_transparent
    public init(_ builder: LavaContainer<Next>) {
        self.builder = builder
    }

    @inlinable @_transparent
    public init(@Lava<Next> _ content: () -> (LavaContainer<Next>)) {
        self.builder = content()
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        assert(result[keyPath: \.pNext] == nil)
        return try builder.withUnsafeResultPointer {
            result[keyPath: \.pNext] = UnsafeRawPointer($0)
            return try body(&result)
        }
    }
}
