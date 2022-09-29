//
//  LVSubStruct.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, SubStruct: InitializableWithNew>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, builder: LavaBuilder<SubStruct>) -> LVSubStruct<Struct, SubStruct> {
    LVSubStruct(path, builder)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, SubStruct: InitializableWithNew>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, @LavaBuilder<SubStruct> _ content: () throws -> (LavaBuilder<SubStruct>)) rethrows -> LVSubStruct<Struct, SubStruct> {
    try LVSubStruct(path, content())
}

public struct LVSubStruct<Struct: InitializableWithNew, SubStruct: InitializableWithNew>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<SubStruct>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let builder: LavaBuilder<SubStruct>

    public init(_ valueKeyPath: ValueKeyPath, _ builder: LavaBuilder<SubStruct>) {
        self.valueKeyPath = valueKeyPath
        self.builder = builder
    }

    @inlinable @inline(__always)
    public func withApplied<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try builder.withUnsafeResultPointer {
            result[keyPath: valueKeyPath] = UnsafePointer($0)
            return try withAppliedDefault(to: &result, tail: tail, body)
        }
    }
}
