//
//  LVString.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.07.2022
//

import TinyFoundation
import CVulkan

@inlinable @inline(__always)
public func <- <Struct: InitializableWithNew, Value: StringProtocol>(path: WritableKeyPath<Struct, UnsafePointer<CChar>?>, value: Value) -> LVString<Struct> {
    LVString(path, String(value))
}

public class LVString<Struct: InitializableWithNew>: LVPath<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<CChar>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: String

    public init(_ valueKeyPath: ValueKeyPath, _ value: String) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.withCString {
            result[keyPath: valueKeyPath] = $0
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}
