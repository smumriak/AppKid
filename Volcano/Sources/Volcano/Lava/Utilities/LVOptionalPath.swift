//
//  LVOptionalPath.swift
//  Volcano
//
//  Created by Serhii Mumriak on 11.01.2023
//

import TinyFoundation

public struct LVOptionalPath<Struct: InitializableWithNew, T: LVPath>: LVPath where T.Struct == Struct {
    @usableFromInline
    let path: T?

    @inlinable @_transparent
    init(_ path: T?) {
        self.path = path
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        if let path {
            return try path.withApplied(to: &result, body: body)
        } else {
            return try body(&result)
        }
    }
}
