//
//  LVBuilder.swift
//  Volcano
//
//  Created by Serhii Mumriak on 21.12.2021.
//

import TinyFoundation
import CVulkan

@resultBuilder
public struct LVBuilder<Struct: InitializableWithNew> {
    public typealias Expression = LVPath<Struct>
    public typealias Component = [LVPath<Struct>]

    public static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }

    public static func buildExpression(_ expression: Expression?) -> Component {
        if let expression = expression {
            return [expression]
        } else {
            return []
        }
    }

    public static func buildBlock() -> Component {
        return []
    }

    public static func buildBlock(_ paths: Component...) -> Component {
        return paths.flatMap { $0 }
    }

    public static func buildBlock(_ paths: [Expression?]) -> Component {
        return paths.compactMap { $0 }
    }

    public static func buildOptional(_ component: Component?) -> Component {
        return component ?? []
    }

    public static func buildEither(first: Component) -> Component {
        return first
    }

    public static func buildEither(second: Component) -> Component {
        return second
    }

    public static func buildArray(_ paths: [Component]) -> Component {
        return paths.flatMap { $0 }
    }

    public static func buildFinalResult(_ paths: Component) -> Component {
        return paths
    }

    public static func buildFinalResult(_ paths: Component) -> LVBuilder<Struct> {
        return LVBuilder(paths)
    }

    public static func buildFinalResult(@LVBuilder<Struct> _ content: () throws -> (Component)) rethrows -> Component {
        return try content()
    }

    public static func buildFinalResult(@LVBuilder<Struct> _ content: () throws -> (LVBuilder<Struct>)) rethrows -> LVBuilder<Struct> {
        return try content()
    }

    @usableFromInline
    internal var paths: Component

    public init(@LVBuilder<Struct> _ content: () throws -> (Component)) rethrows {
        try self.init(content())
    }

    @usableFromInline
    internal init(_ paths: Component) {
        self.paths = paths
    }

    @inlinable @inline(__always)
    internal func withUnsafeMutableResultPointer<R>(_ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        var result = Struct.new()

        if paths.isEmpty {
            return try withUnsafeMutablePointer(to: &result, body)
        } else {
            let indices = paths.indices

            let head = paths[indices.lowerBound]
            let tail = paths[indices.dropFirst()]

            return try head.withApplied(to: &result, tail: tail, body)
        }
    }

    @inlinable @inline(__always)
    public func withUnsafeResultPointer<R>(_ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeMutableResultPointer {
            try body(UnsafePointer($0))
        }
    }

    @inlinable @inline(__always)
    public func callAsFunction<R>(_ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeResultPointer(body)
    }
}

public extension HandleStorage where Handle.Pointee: EntityFactory {
    func buildEntity<Info: SimpleEntityInfo>(_ type: Info.Type = Info.self, _ builder: LVBuilder<Info>) throws -> SmartPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try builder.withUnsafeResultPointer {
            try create(with: $0)
        }
    }

    func buildEntity<Info: SimpleEntityInfo>(_ type: Info.Type = Info.self, @LVBuilder<Info> _ content: () throws -> (LVBuilder<Info>)) throws -> SmartPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try buildEntity(type, content())
    }

    func buildEntity<Info: PipelineEntityInfo>(_ type: Info.Type = Info.self, cache: VkPipelineCache? = nil, _ builder: LVBuilder<Info>) throws -> SmartPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try builder.withUnsafeResultPointer {
            try create(with: $0, cache: cache)
        }
    }

    func buildEntity<Info: PipelineEntityInfo>(_ type: Info.Type = Info.self, cache: VkPipelineCache? = nil, @LVBuilder<Info> _ content: () throws -> (LVBuilder<Info>)) throws -> SmartPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try buildEntity(type, cache: cache, content())
    }
}
