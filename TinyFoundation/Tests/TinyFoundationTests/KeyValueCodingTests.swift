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
        XCTAssertEqual(value.storedValue, CGRect(x: 12.0, y: 0.0, width: 0.0, height: 42.0))
    }
}
