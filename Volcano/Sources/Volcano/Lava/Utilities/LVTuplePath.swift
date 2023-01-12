//
//  LVTuplePath.swift
//  Volcano
//
//  Created by Serhii Mumriak on 10.01.2023
//

import TinyFoundation

public struct LVTuplePath<Struct: InitializableWithNew, L: LVPath, R: LVPath>: LVPath where L.Struct == Struct, R.Struct == Struct {
    @usableFromInline
    let left: L
    
    @usableFromInline
    let right: R

    @inlinable @_transparent
    init(left: L, right: R) {
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
