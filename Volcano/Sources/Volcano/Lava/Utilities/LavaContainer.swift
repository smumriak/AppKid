//
//  LavaContainer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 31.03.2023
//

import TinyFoundation

internal extension LavaContainer {
    @inlinable @_transparent
    func withApplied<R>(to result: inout [Struct], tail: ArraySlice<LavaContainer<Struct>>, _ body: (UnsafeBufferPointer<Struct>) throws -> (R)) rethrows -> R {
        return try withUnsafeResultPointer {
            result.append($0.pointee)

            let indices = tail.indices
            if indices.lowerBound == indices.upperBound {
                return try result.withUnsafeBufferPointer(body)
            } else {
                let nextHead = tail[indices.lowerBound]
                let nextTail = tail[indices.dropFirst()]

                return try nextHead.withApplied(to: &result, tail: nextTail, body)
            }
        }
    }
}

public struct LavaContainer<Struct: InitializableWithNew>: LVPath {
    @usableFromInline
    let path: any LVPath<Struct>

    @inlinable @_transparent
    init<T: LVPath>(_ path: T) where T.Struct == Struct {
        self.path = path
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        return try path.withApplied(to: &result, body: body)
    }
}

public struct LavaContainerArray<Struct: InitializableWithNew> {
    @usableFromInline
    internal var elements: [LavaContainer<Struct>]

    @usableFromInline
    internal init(_ elements: [LavaContainer<Struct>]) {
        self.elements = elements
    }

    @inlinable @_transparent
    public func withUnsafeResultPointer<R>(_ body: (UnsafeBufferPointer<Struct>) throws -> (R)) rethrows -> R {
        var result: [Struct] = []

        if elements.isEmpty {
            return try result.withUnsafeBufferPointer(body)
        } else {
            result.reserveCapacity(elements.count)

            let indices = elements.indices

            let head = elements[indices.lowerBound]
            let tail = elements[indices.dropFirst()]

            return try head.withApplied(to: &result, tail: tail, body)
        }
    }

    @inlinable @_transparent
    public func callAsFunction<R>(_ body: (UnsafeBufferPointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeResultPointer(body)
    }
}
