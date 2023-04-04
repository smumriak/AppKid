//
//  Lava.swift
//  Volcano
//
//  Created by Serhii Mumriak on 21.12.2021.
//

import TinyFoundation
import CVulkan

@resultBuilder
public struct Lava<Struct: InitializableWithNew> {
    @inlinable @_transparent
    public static func buildExpression(_ expression: some LVPath<Struct>) -> some LVPath<Struct> {
        expression
    }

    @inlinable @_transparent
    public static func buildBlock() -> some LVPath<Struct> {
        LVEmptyPath()
    }
    
    @inlinable @_transparent
    public static func buildPartialBlock(first: some LVPath<Struct>) -> some LVPath<Struct> {
        first
    }

    @inlinable @_transparent
    public static func buildPartialBlock(accumulated left: some LVPath<Struct>, next right: some LVPath<Struct>) -> some LVPath<Struct> {
        LVTuplePath(left: left, right: right)
    }

    @inlinable @_transparent
    public static func buildOptional(_ component: (some LVPath<Struct>)?) -> some LVPath<Struct> {
        LVOptionalPath(component)
    }

    // smumriak: https://github.com/apple/swift/issues/57076 ([SR-14726]). Till this is fixed functionality of "else" and "switch" in Lava will be disabled
    // @inlinable @_transparent
    // public static func buildEither(first component: some LVPath<Struct>) -> some LVPath<Struct> {
    //     component
    // }

    // @inlinable @_transparent
    // public static func buildEither(second component: some LVPath<Struct>) -> some LVPath<Struct> {
    //     component
    // }

    @inlinable @_transparent
    public static func buildFinalResult<T: LVPath>(_ component: T) -> LavaContainer<Struct> where T.Struct == Struct {
        LavaContainer(component)
    }

    @usableFromInline
    internal var path: any LVPath<Struct>

    @inlinable @_transparent
    public init<Path: LVPath>(@Lava<Struct> _ content: () throws -> (Path)) rethrows where Path.Struct == Struct {
        try self.init(content())
    }

    @inlinable @_transparent
    public init<Path: LVPath>(_ path: Path) where Path.Struct == Struct {
        self.path = path
    }

    @inlinable @_transparent
    public func withUnsafeMutableResultPointer<R>(_ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        var result = Struct.new()
        return try path.withApplied(to: &result) {
            try withUnsafeMutablePointer(to: &$0, body)
        }
    }

    @inlinable @_transparent
    public func withUnsafeResultPointer<R>(_ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeMutableResultPointer {
            try body(UnsafePointer($0))
        }
    }

    @inlinable @_transparent
    public func callAsFunction<R>(_ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeResultPointer(body)
    }
}

public extension SharedPointerStorage where Handle.Pointee: EntityFactory {
    @inlinable @_transparent
    func buildEntity<Info: PipelineEntityInfo>(context: UnsafePointer<Info.Context>?, _ container: LavaContainer<Info>) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try container {
            try create(with: $0, context: context)
        }
    }

    @inlinable @_transparent
    func buildEntity<Info: PipelineEntityInfo>(context: UnsafePointer<Info.Context>?, @Lava<Info> _ content: () throws -> (LavaContainer<Info>)) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try buildEntity(context: context, content())
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromSingleEntityInfo>(_ container: LavaContainer<Result.Info>) throws -> SharedPointer<Result> where Result.Info: SimpleEntityInfo, Result.Info.Parent == Handle.Pointee {
        try container {
            try create(with: $0)
        }
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromSingleEntityInfo>(@Lava<Result.Info> _ content: () throws -> (LavaContainer<Result.Info>)) throws -> SharedPointer<Result> where Result.Info: SimpleEntityInfo, Result.Info.Parent == Handle.Pointee {
        try buildEntity(content())
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromTwoEntityInfos>(_ container: LavaContainer<Result.Info2>) throws -> SharedPointer<Result> where Result.Info2: SimpleEntityInfo, Result.Info2.Parent == Handle.Pointee {
        try container {
            try create(with: $0)
        }
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromTwoEntityInfos>(@Lava<Result.Info2> _ content: () throws -> (LavaContainer<Result.Info2>)) throws -> SharedPointer<Result> where Result.Info2: SimpleEntityInfo, Result.Info2.Parent == Handle.Pointee {
        try buildEntity(content())
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromThreeEntityInfos>(_ container: LavaContainer<Result.Info3>) throws -> SharedPointer<Result> where Result.Info3: SimpleEntityInfo, Result.Info3.Parent == Handle.Pointee {
        try container {
            try create(with: $0)
        }
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromThreeEntityInfos>(@Lava<Result.Info3> _ content: () throws -> (LavaContainer<Result.Info3>)) throws -> SharedPointer<Result> where Result.Info3: SimpleEntityInfo, Result.Info3.Parent == Handle.Pointee {
        try buildEntity(content())
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromFourEntityInfos>(_ container: LavaContainer<Result.Info4>) throws -> SharedPointer<Result> where Result.Info4: SimpleEntityInfo, Result.Info4.Parent == Handle.Pointee {
        try container {
            try create(with: $0)
        }
    }

    @inlinable @_transparent
    func buildEntity<Result: CreateableFromFourEntityInfos>(@Lava<Result.Info4> _ content: () throws -> (LavaContainer<Result.Info4>)) throws -> SharedPointer<Result> where Result.Info4: SimpleEntityInfo, Result.Info4.Parent == Handle.Pointee {
        try buildEntity(content())
    }
}
