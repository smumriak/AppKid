//
//  WithUnsafePointerOrNil.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 01.09.2020.
//

public extension Optional {
    func withUnsafePointerOrNil<R>(body: (UnsafePointer<Wrapped>?) throws -> (R)) rethrows -> R {
        switch self {
        case .none:
            return try body(nil)
        case .some(let value):
            return try withUnsafePointer(to: value) { try body($0) }
        }
    }
}

public func withUnsafeBufferPointerOrNil<T, R>(_ array: [T]?, body: (UnsafeBufferPointer<T>?) throws -> (R)) rethrows -> R {
    switch array {
    case .none:
        return try body(nil)
    case .some(let value):
        return try value.withUnsafeBufferPointer { try body($0) }
    }
}
