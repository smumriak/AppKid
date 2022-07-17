//
//  LVSubStruct.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, SubStruct: InitializableWithNew>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, builder: LVBuilder<SubStruct>) -> LVSubStruct<Struct, SubStruct> {
    LVSubStruct(path, builder)
}

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, SubStruct: InitializableWithNew>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, @LVBuilder<SubStruct> _ content: () throws -> (LVBuilder<SubStruct>)) rethrows -> LVSubStruct<Struct, SubStruct> {
    try LVSubStruct(path, content())
}

public class LVSubStruct<Struct: InitializableWithNew, SubStruct: InitializableWithNew>: LVPath<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<SubStruct>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let builder: LVBuilder<SubStruct>

    public init(_ valueKeyPath: ValueKeyPath, _ builder: LVBuilder<SubStruct>) {
        self.valueKeyPath = valueKeyPath
        self.builder = builder
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try builder.withUnsafeResultPointer {
            result[keyPath: valueKeyPath] = UnsafePointer($0)
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}
