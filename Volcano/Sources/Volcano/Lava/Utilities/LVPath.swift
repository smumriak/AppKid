//
//  LVPath.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022.
//

import TinyFoundation

public protocol LVPath<Struct> {
    associatedtype Struct: InitializableWithNew
    
    @inlinable @inline(__always)
    func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R
}

public extension LVPath {
    @inlinable @_transparent
    func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        try body(&result)
    }

    @inlinable @_transparent
    func withUnsafeMutableResultPointer<R>(_ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        var result = Struct.new()
        return try withApplied(to: &result) {
            try withUnsafeMutablePointer(to: &$0, body)
        }
    }

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
