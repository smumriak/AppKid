//
//  LVPath.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022.
//

import TinyFoundation

public protocol LVPath<Struct> {
    associatedtype Struct: InitializableWithNew
    func withApplied<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R
}

public extension LVPath {
    func withApplied<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        try withAppliedDefault(to: &result, tail: tail, body)
    }

    @inlinable @inline(__always)
    func withAppliedDefault<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        let indices = tail.indices
        if indices.lowerBound == indices.upperBound {
            return try withUnsafeMutablePointer(to: &result) {
                try body($0)
            }
        } else {
            let nextHead = tail[indices.lowerBound]
            let nextTail = tail[indices.dropFirst()]

            return try nextHead.withApplied(to: &result, tail: nextTail, body)
        }
    }
}
