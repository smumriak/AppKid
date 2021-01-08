//
//  CStringUtils.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.06.2020.
//

import Foundation

public extension Array where Element == String {
    var cStrings: [SmartPointer<Int8>] {
        let deleter = SmartPointer<Int8>.Deleter.custom { free($0) }

        return map {
            SmartPointer<Int8>(with: strdup($0), deleter: deleter)
        }
    }

    func withUnsafeNullableCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<Int8>?>) throws -> (R)) throws -> R {
        let cStrings = self.cStrings

        return try cStrings.map { UnsafePointer($0.pointer) as UnsafePointer<Int8>? }.withUnsafeBufferPointer(body)
    }

    func withUnsafeCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<Int8>>) throws -> (R)) throws -> R {
        let cStrings = self.cStrings

        return try cStrings.map { UnsafePointer($0.pointer) }.withUnsafeBufferPointer(body)
    }
}
