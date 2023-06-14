//
//  LVTuplePath.swift
//  Volcano
//
//  Created by Serhii Mumriak on 10.01.2023
//

import TinyFoundation

public struct LVTuplePath<Struct: InitializableWithNew, Left: LVPath, Right: LVPath>: LVPath where Left.Struct == Struct, Right.Struct == Struct {
    @usableFromInline
    let left: Left

    @usableFromInline
    let right: Right

    @inlinable @_transparent
    init(left: Left, right: Right) {
        self.left = left
        self.right = right
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        try left.withApplied(to: &result) {
            try right.withApplied(to: &$0) {
                try body(&$0)
            }
        }
    }
}
