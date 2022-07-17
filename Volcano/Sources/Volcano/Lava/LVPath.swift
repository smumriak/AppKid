//
//  LVPath.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022.
//

import TinyFoundation

public class LVPath<Struct: InitializableWithNew> {
    @inlinable @inline(__always)
    public func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        let indices = tail.indices
        if indices.lowerBound == indices.upperBound {
            return try withUnsafeMutablePointer(to: &result) {
                return try body($0)
            }
        } else {
            let nextHead = tail[indices.lowerBound]
            let nextTail = tail[indices.dropFirst()]

            return try nextHead.withApplied(to: &result, tail: nextTail, body)
        }
    }
}
