//
//  CStringUtils.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.06.2020.
//

import Foundation

public extension Array where Element == String {
    var cStrings: [SmartPointer<CChar>] {
        let deleter = SmartPointer<Int8>.Deleter.custom { free($0) }

        return map {
            SmartPointer<Int8>(with: strdup($0), deleter: deleter)
        }
    }

    func withUnsafeNullableCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<CChar>?>) throws -> (R)) rethrows -> R {
        let cStrings = self.cStrings

        return try cStrings.optionalPointers().withUnsafeBufferPointer(body)
    }

    func withUnsafeCStringsBufferPointer<R>(_ body: (UnsafeBufferPointer<UnsafePointer<CChar>>) throws -> (R)) rethrows -> R {
        let cStrings = self.cStrings

        return try cStrings.pointers().withUnsafeBufferPointer(body)
    }
}

public extension Set where Element == String {
    var cStrings: [SmartPointer<Int8>] {
        let deleter = SmartPointer<Int8>.Deleter.custom { free($0) }

        return map {
            SmartPointer<Int8>(with: strdup($0), deleter: deleter)
        }
    }
}
