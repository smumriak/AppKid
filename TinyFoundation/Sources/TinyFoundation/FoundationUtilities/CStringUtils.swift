//
//  CStringUtils.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.06.2020.
//

import Foundation

// MARK: Arrays of C Strings

public extension Array where Element: StringProtocol {
    @_transparent
    var cStrings: [SharedPointer<CChar>] {
        let deleter = SharedPointer<Int8>.Deleter.custom { free($0) }

        return map {
            SharedPointer<Int8>(with: $0.withCString { strdup($0) }, deleter: deleter)
        }
    }

    @_transparent
    func withUnsafeNullableCStringsArray<R>(_ body: ([UnsafePointer<CChar>?]) throws -> (R)) rethrows -> R {
        let cStrings = self.cStrings

        return try body(cStrings.optionalPointers())
    }

    @_transparent
    func withUnsafeNullableCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<CChar>?>) throws -> (R)) rethrows -> R {
        try withUnsafeNullableCStringsArray {
            try $0.withUnsafeBufferPointer(body)
        }
    }

    @_transparent
    func withUnsafeCStringsBufferPointer<R>(_ body: ([UnsafePointer<CChar>]) throws -> (R)) rethrows -> R {
        let cStrings = self.cStrings

        return try body(cStrings.pointers())
    }

    @_transparent
    func withUnsafeCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<CChar>>) throws -> (R)) rethrows -> R {
        try withUnsafeCStringsBufferPointer {
            try $0.withUnsafeBufferPointer(body)
        }
    }

    @_transparent
    func withUnsafeNulllTerminatedCStringsArray<R>(_ body: (UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) throws -> (R)) rethrows -> R {
        let array = nullTerminatedArrayOfCStrings
        defer {
            for i in 0..<count {
                (array + i).pointee?.deallocate()
            }
            nullTerminatedArrayOfCStrings.deinitialize(count: count + 1)
            nullTerminatedArrayOfCStrings.deallocate()
        }

        return try body(array)
    }

    @_transparent
    var nullTerminatedArrayOfCStrings: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?> {
        let size = count + 1
        let result: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?> = .allocate(capacity: size)
        result.initialize(repeating: nil, count: size)

        let buffer = UnsafeMutableBufferPointer(start: result, count: size)

        for (index, element) in enumerated() {
            buffer[index] = element.withCString { strdup($0) }
        }
        
        return result
    }
}

public extension Set where Element: StringProtocol {
    @_transparent
    var cStrings: [SharedPointer<Int8>] {
        let deleter = SharedPointer<Int8>.Deleter.custom { free($0) }

        return map {
            SharedPointer<Int8>(with: $0.withCString { strdup($0) }, deleter: deleter)
        }
    }
}

// MARK: Null-terminated arrays of C Strings

// these things are nullable by definition of "null-terminated array"
public extension Array where Element: StringProtocol {
    @_transparent
    func withNullTerminatedCStringsArray<R>(_ body: ([UnsafePointer<CChar>?]) throws -> R) rethrows -> R {
        let cStrings = self.cStrings

        return try body(cStrings.pointers() + [nil])
    }

    @_transparent
    func withUnsafeNullTerminatedCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<CChar>?>) throws -> R) rethrows -> R {
        try withNullTerminatedCStringsArray {
            try $0.withUnsafeBufferPointer(body)
        }
    }

    @_transparent
    func withNullTerminatedMutableCStringsArray<R>(_ body: ([UnsafeMutablePointer<CChar>?]) throws -> R) rethrows -> R {
        let cStrings = self.cStrings

        return try body(cStrings.mutablePointers() + [nil])
    }

    @_transparent
    func withUnsafeNullTerminatedMutableCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafeMutablePointer<CChar>?>) throws -> R) rethrows -> R {
        try withNullTerminatedMutableCStringsArray {
            try $0.withUnsafeBufferPointer(body)
        }
    }
}

// MARK: C String tuples

public extension StringProtocol {
    @_transparent
    init<T>(cStringTuple: T) {
        self = withUnsafePointer(to: cStringTuple) { cStringTuple in
            return cStringTuple.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: cStringTuple)) { cString in
                return Self(cString: cString)
            }
        }
    }
}
