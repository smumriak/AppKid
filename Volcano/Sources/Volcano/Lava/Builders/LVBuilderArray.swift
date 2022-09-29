//
//  LVBuilderArray.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.12.2021.
//

import TinyFoundation
import CVulkan

internal extension LVBuilder {
    @inlinable @inline(__always)
    func withApplied<R>(to result: inout [Struct], tail: ArraySlice<LVBuilder<Struct>>, _ body: (UnsafeBufferPointer<Struct>) throws -> (R)) rethrows -> R {
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

@resultBuilder
public struct LVBuilderArray<Struct: VulkanStructure> {
    public typealias Expression = LVBuilder<Struct>
    public typealias Component = [LVBuilder<Struct>]

    static func buildExpression() -> Component {
        return []
    }

    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }

    static func buildExpression(_ expression: Expression?) -> Component {
        if let expression = expression {
            return [expression]
        } else {
            return []
        }
    }

    static func buildBlock(_ elements: [Expression?]) -> Component {
        return elements.compactMap { $0 }
    }

    static func buildBlock(_ elements: Component...) -> Component {
        return elements.flatMap { $0 }
    }

    static func buildOptional(_ component: Component?) -> Component {
        return component ?? []
    }

    static func buildEither(first: Component) -> Component {
        return first
    }

    static func buildEither(second: Component) -> Component {
        return second
    }

    static func buildArray(_ elements: [Component]) -> Component {
        return elements.flatMap { $0 }
    }

    static func buildFinalResult(_ elements: Component) -> Component {
        return elements
    }

    static func buildFinalResult(_ elements: Component) -> LVBuilderArray<Struct> {
        return LVBuilderArray(elements)
    }

    static func buildFinalResult(@LVBuilderArray<Struct> _ content: () -> (Component)) -> LVBuilderArray<Struct> {
        return LVBuilderArray(content())
    }

    static func buildFinalResult(@LVBuilderArray<Struct> _ content: () -> (LVBuilderArray<Struct>)) -> LVBuilderArray<Struct> {
        return content()
    }

    @usableFromInline
    internal var elements: Component

    @usableFromInline
    internal init(@LVBuilderArray<Struct> _ content: () throws -> (Component)) rethrows {
        self.elements = try content()
    }

    @usableFromInline
    internal init(_ elements: Component) {
        self.elements = elements
    }

    @inlinable @inline(__always)
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

    @inlinable @inline(__always)
    public func callAsFunction<R>(_ body: (UnsafeBufferPointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeResultPointer(body)
    }
}

public extension HandleStorage where Handle.Pointee: EntityFactory {
    func buildEntities<Info: PipelineEntityInfo>(_ type: Info.Type = Info.self, cache: VkPipelineCache?, _ builder: LVBuilderArray<Info>) throws -> [SharedPointer<Info.Result>] where Info.Parent == Handle.Pointee {
        try builder.withUnsafeResultPointer {
            try create(with: $0, cache: cache)
        }
    }

    func buildEntities<Info: PipelineEntityInfo>(_ type: Info.Type = Info.self, cache: VkPipelineCache?, @LVBuilderArray<Info> _ content: () throws -> (LVBuilderArray<Info>)) throws -> [SharedPointer<Info.Result>] where Info.Parent == Handle.Pointee {
        try buildEntities(type, cache: cache, content())
    }
}
