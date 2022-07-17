//
//  LVNextChainStruct.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public prefix func <- <Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(builder: LVBuilder<NextStruct>) -> LVNextChainStruct<Struct, NextStruct> {
    LVNextChainStruct(builder)
}

@inlinable @inline(__always)
public prefix func <- <Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(@LVBuilder<NextStruct> _ content: () throws -> LVBuilder<NextStruct>) rethrows -> LVNextChainStruct<Struct, NextStruct> {
    try LVNextChainStruct(content())
}

@inlinable @inline(__always)
public func next<Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(_: NextStruct.Type, @LVBuilder<NextStruct> _ content: () throws -> LVBuilder<NextStruct>) rethrows -> LVNextChainStruct<Struct, NextStruct> {
    try LVNextChainStruct(content())
}

public class LVNextChainStruct<Struct: VulkanChainableStructure, Next: VulkanChainableStructure>: LVPath<Struct> {
    @usableFromInline
    internal let builder: LVBuilder<Next>

    public init(_ builder: LVBuilder<Next>) {
        self.builder = builder
    }

    public init(@LVBuilder<Next> _ content: () -> (LVBuilder<Next>)) {
        self.builder = content()
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        assert(result[keyPath: \.pNext] == nil)
        return try builder.withUnsafeResultPointer {
            result[keyPath: \.pNext] = UnsafeRawPointer($0)
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}
