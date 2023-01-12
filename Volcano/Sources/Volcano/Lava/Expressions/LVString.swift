//
//  LVString.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @_transparent
public func <- <Struct: InitializableWithNew, Value: StringProtocol>(path: WritableKeyPath<Struct, UnsafePointer<CChar>?>, value: Value) -> LVString<Struct> {
    LVString(path, String(value))
}

public struct LVString<Struct: InitializableWithNew>: LVPath {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<CChar>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: String

    @inlinable @_transparent
    public init(_ valueKeyPath: ValueKeyPath, _ value: String) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @_transparent
    public func withApplied<R>(to result: inout Struct, body: (inout Struct) throws -> (R)) rethrows -> R {
        return try value.withCString {
            result[keyPath: valueKeyPath] = $0
            return try body(&result)
        }
    }
}
