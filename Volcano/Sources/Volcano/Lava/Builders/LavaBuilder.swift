//
//  LavaBuilder.swift
//  Volcano
//
//  Created by Serhii Mumriak on 21.12.2021.
//

import TinyFoundation
import CVulkan

@resultBuilder
public struct LavaBuilder<Struct: InitializableWithNew> {
    public static func buildExpression(_ expression: any LVPath<Struct>) -> [any LVPath<Struct>] {
        return [expression]
    }

    public static func buildExpression(_ expression: (any LVPath<Struct>)?) -> [any LVPath<Struct>] {
        if let expression = expression {
            return [expression]
        } else {
            return []
        }
    }

    public static func buildBlock() -> [any LVPath<Struct>] {
        return []
    }

    public static func buildBlock(_ paths: [any LVPath<Struct>]...) -> [any LVPath<Struct>] {
        return paths.flatMap { $0 }
    }

    public static func buildBlock(_ paths: [(any LVPath<Struct>)?]) -> [any LVPath<Struct>] {
        return paths.compactMap { $0 }
    }

    public static func buildOptional(_ component: [any LVPath<Struct>]?) -> [any LVPath<Struct>] {
        return component ?? []
    }

    public static func buildEither(first: [any LVPath<Struct>]) -> [any LVPath<Struct>] {
        return first
    }

    public static func buildEither(second: [any LVPath<Struct>]) -> [any LVPath<Struct>] {
        return second
    }

    public static func buildArray(_ paths: [[any LVPath<Struct>]]) -> [any LVPath<Struct>] {
        return paths.flatMap { $0 }
    }

    public static func buildFinalResult(_ paths: [any LVPath<Struct>]) -> [any LVPath<Struct>] {
        return paths
    }

    public static func buildFinalResult(_ paths: [any LVPath<Struct>]) -> LavaBuilder<Struct> {
        return LavaBuilder(paths)
    }

    public static func buildFinalResult(@LavaBuilder<Struct> _ content: () throws -> ([any LVPath<Struct>])) rethrows -> [any LVPath<Struct>] {
        return try content()
    }

    public static func buildFinalResult(@LavaBuilder<Struct> _ content: () throws -> (LavaBuilder<Struct>)) rethrows -> LavaBuilder<Struct> {
        return try content()
    }

    @usableFromInline
    internal var paths: [any LVPath<Struct>]

    public init(@LavaBuilder<Struct> _ content: () throws -> ([any LVPath<Struct>])) rethrows {
        try self.init(content())
    }

    @usableFromInline
    internal init(_ paths: [any LVPath<Struct>]) {
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

public extension SharedPointerStorage where Handle.Pointee: EntityFactory {
    func buildEntity<Info: SimpleEntityInfo>(_ type: Info.Type = Info.self, _ builder: LavaBuilder<Info>) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try builder.withUnsafeResultPointer {
            try create(with: $0)
        }
    }

    func buildEntity<Info: SimpleEntityInfo>(_ type: Info.Type = Info.self, @LavaBuilder<Info> _ content: () throws -> (LavaBuilder<Info>)) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try buildEntity(type, content())
    }

    func buildEntity<Info: PipelineEntityInfo>(_ type: Info.Type = Info.self, cache: VkPipelineCache? = nil, _ builder: LavaBuilder<Info>) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try builder.withUnsafeResultPointer {
            try create(with: $0, cache: cache)
        }
    }

    func buildEntity<Info: PipelineEntityInfo>(_ type: Info.Type = Info.self, cache: VkPipelineCache? = nil, @LavaBuilder<Info> _ content: () throws -> (LavaBuilder<Info>)) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try buildEntity(type, cache: cache, content())
    }
}
