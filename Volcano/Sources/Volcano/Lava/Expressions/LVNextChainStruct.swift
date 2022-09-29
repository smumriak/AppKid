//
//  LVNextChainStruct.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public prefix func <- <Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(builder: LavaBuilder<NextStruct>) -> LVNextChainStruct<Struct, NextStruct> {
    LVNextChainStruct(builder)
}

@inlinable @inline(__always)
public prefix func <- <Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(@LavaBuilder<NextStruct> _ content: () throws -> LavaBuilder<NextStruct>) rethrows -> LVNextChainStruct<Struct, NextStruct> {
    try LVNextChainStruct(content())
}

@inlinable @inline(__always)
public func next<Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(_: NextStruct.Type, @LavaBuilder<NextStruct> _ content: () throws -> LavaBuilder<NextStruct>) rethrows -> LVNextChainStruct<Struct, NextStruct> {
    try LVNextChainStruct(content())
}

public struct LVNextChainStruct<Struct: VulkanChainableStructure, Next: VulkanChainableStructure>: LVPath {
    @usableFromInline
    internal let builder: LavaBuilder<Next>

    public init(_ builder: LavaBuilder<Next>) {
        self.builder = builder
    }

    public init(@LavaBuilder<Next> _ content: () -> (LavaBuilder<Next>)) {
        self.builder = content()
    }

    @inlinable @inline(__always)
    public func withApplied<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        assert(result[keyPath: \.pNext] == nil)
        return try builder.withUnsafeResultPointer {
            result[keyPath: \.pNext] = UnsafeRawPointer($0)
            return try withAppliedDefault(to: &result, tail: tail, body)
        }
    }
}
