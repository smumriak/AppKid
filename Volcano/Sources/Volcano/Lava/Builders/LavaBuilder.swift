//
//  LavaBuilder.swift
//  Volcano
//
//  Created by Serhii Mumriak on 21.12.2021.
//

import TinyFoundation
import CVulkan

public protocol LavaBuilderProtocol<Struct> {
    associatedtype Struct: InitializableWithNew
    
    @inlinable @inline(__always)
    func withUnsafeMutableResultPointer<R>(_ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R
}

public extension LavaBuilderProtocol {
    @inlinable @_transparent
    func withUnsafeResultPointer<R>(_ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeMutableResultPointer {
            try body(UnsafePointer($0))
        }
    }

    @inlinable @_transparent
    func callAsFunction<R>(_ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        try withUnsafeResultPointer(body)
    }
}

@resultBuilder
public struct LavaBuilder<Struct: InitializableWithNew>: LavaBuilderProtocol {
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
    public static func buildFinalResult(_ component: some LVPath<Struct>) -> some LVPath<Struct> {
        component
    }

    @inlinable @_transparent
    public static func buildFinalResult(_ component: some LVPath<Struct>) -> LavaBuilder<Struct> {
        LavaBuilder(component)
    }

    @inlinable @_transparent
    public static func buildFinalResult(@LavaBuilder<Struct> _ content: () throws -> (some LVPath<Struct>)) rethrows -> some LVPath<Struct> {
        try content()
    }

    @inlinable @_transparent
    public static func buildFinalResult(@LavaBuilder<Struct> _ content: () throws -> (LavaBuilder<Struct>)) rethrows -> LavaBuilder<Struct> {
        try content()
    }

    @usableFromInline
    internal var path: any LVPath<Struct>

    @inlinable @_transparent
    public init<Path: LVPath>(@LavaBuilder<Struct> _ content: () throws -> (Path)) rethrows where Path.Struct == Struct {
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
}

public extension SharedPointerStorage where Handle.Pointee: EntityFactory {
    func buildEntity<Info: PipelineEntityInfo>(context: UnsafePointer<Info.Context>?, _ builder: LavaBuilder<Info>) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try builder {
            try create(with: $0, context: context)
        }
    }

    func buildEntity<Info: PipelineEntityInfo>(context: UnsafePointer<Info.Context>?, @LavaBuilder<Info> _ content: () throws -> (LavaBuilder<Info>)) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try buildEntity(context: context, content())
    }

    func buildEntity<Result: CreateableFromSingleEntityInfo>(_ builder: LavaBuilder<Result.Info>) throws -> SharedPointer<Result> where Result.Info: SimpleEntityInfo, Result.Info.Parent == Handle.Pointee {
        try builder {
            try create(with: $0)
        }
    }

    func buildEntity<Result: CreateableFromSingleEntityInfo>(@LavaBuilder<Result.Info> _ content: () throws -> (LavaBuilder<Result.Info>)) throws -> SharedPointer<Result> where Result.Info: SimpleEntityInfo, Result.Info.Parent == Handle.Pointee {
        try buildEntity(content())
    }

    func buildEntity<Result: CreateableFromTwoEntityInfos>(_ builder: LavaBuilder<Result.Info2>) throws -> SharedPointer<Result> where Result.Info2: SimpleEntityInfo, Result.Info2.Parent == Handle.Pointee {
        try builder {
            try create(with: $0)
        }
    }

    func buildEntity<Result: CreateableFromTwoEntityInfos>(@LavaBuilder<Result.Info2> _ content: () throws -> (LavaBuilder<Result.Info2>)) throws -> SharedPointer<Result> where Result.Info2: SimpleEntityInfo, Result.Info2.Parent == Handle.Pointee {
        try buildEntity(content())
    }

    func buildEntity<Result: CreateableFromThreeEntityInfos>(_ builder: LavaBuilder<Result.Info3>) throws -> SharedPointer<Result> where Result.Info3: SimpleEntityInfo, Result.Info3.Parent == Handle.Pointee {
        try builder {
            try create(with: $0)
        }
    }

    func buildEntity<Result: CreateableFromThreeEntityInfos>(@LavaBuilder<Result.Info3> _ content: () throws -> (LavaBuilder<Result.Info3>)) throws -> SharedPointer<Result> where Result.Info3: SimpleEntityInfo, Result.Info3.Parent == Handle.Pointee {
        try buildEntity(content())
    }

    func buildEntity<Result: CreateableFromFourEntityInfos>(_ builder: LavaBuilder<Result.Info4>) throws -> SharedPointer<Result> where Result.Info4: SimpleEntityInfo, Result.Info4.Parent == Handle.Pointee {
        try builder {
            try create(with: $0)
        }
    }

    func buildEntity<Result: CreateableFromFourEntityInfos>(@LavaBuilder<Result.Info4> _ content: () throws -> (LavaBuilder<Result.Info4>)) throws -> SharedPointer<Result> where Result.Info4: SimpleEntityInfo, Result.Info4.Parent == Handle.Pointee {
        try buildEntity(content())
    }
}
