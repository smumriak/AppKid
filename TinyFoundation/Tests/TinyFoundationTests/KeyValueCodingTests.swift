//
//  KeyValueCodingTests.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 25.11.2021.
//

import XCTest
@testable import TinyFoundation

final class KeyValueCodingTests: XCTestCase {
    func testSimple() throws {
        let value = Value(CGRect())
        value.setValue(CGFloat(12), forKeyPath: "origin.x")
        value.setValue(CGFloat(42), forKeyPath: "size.height")
        debugPrint(value.storedValue)
        XCTAssert(true)
    }
}
