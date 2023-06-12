//
//  LVSubStruct.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, SubStruct: InitializableWithNew>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, builder: LavaContainer<SubStruct>) -> LVSubStruct<Struct, SubStruct> {
    LVSubStruct(path, builder)
}

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, SubStruct: InitializableWithNew>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, @Lava<SubStruct> _ content: () throws -> (LavaContainer<SubStruct>)) rethrows -> LVSubStruct<Struct, SubStruct> {
    try LVSubStruct(path, content())
}

public struct LVSubStruct<Struct: InitializableWithNew, SubStruct: InitializableWithNew>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<SubStruct>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let builder: LavaContainer<SubStruct>

    @inlinable @_transparent
    public init(_ valueKeyPath: ValueKeyPath, _ builder: LavaContainer<SubStruct>) {
        self.valueKeyPath = valueKeyPath
        self.builder = builder
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        return try builder.withUnsafeResultPointer {
            result[keyPath: valueKeyPath] = UnsafePointer($0)
            return try body(&result)
        }
    }
}
