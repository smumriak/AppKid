//
//  BinarySearchTests.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 05.02.2023
//

import XCTest
@testable import TinyFoundation

final class BinarySearchTests: XCTestCase {
    let array = [-18, -14, -11, -9, -9, -9, -8, -7, -6, -5, -4, -1, 0, 0, 0, 3, 10, 14, 14, 14, 17, 20]
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSimple() {
        var value = -9
        var expectedIndex = 4
        var result = array.findInsertionIndex(for: value, options: .anyEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 16
        result = array.reversed().findInsertionIndex(for: value, options: .anyEqual, by: >)
        XCTAssertEqual(result, expectedIndex)

        value = 0
        expectedIndex = 13
        result = array.findInsertionIndex(for: value, options: .anyEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 7
        result = array.reversed().findInsertionIndex(for: value, options: .anyEqual, by: >)
        XCTAssertEqual(result, expectedIndex)
    }

    func testMostLeft() {
        var value = -9
        var expectedIndex = 3
        var result = array.findInsertionIndex(for: value, options: .firstEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 16
        result = array.reversed().findInsertionIndex(for: value, options: .firstEqual, by: >)
        XCTAssertEqual(result, expectedIndex)

        value = -0
        expectedIndex = 12
        result = array.findInsertionIndex(for: value, options: .firstEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 7
        result = array.reversed().findInsertionIndex(for: value, options: .firstEqual, by: >)
        XCTAssertEqual(result, expectedIndex)
    }

    func testMostRight() {
        var value = -9
        var expectedIndex = 6
        var result = array.findInsertionIndex(for: value, options: .lastEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 19
        result = array.reversed().findInsertionIndex(for: value, options: .lastEqual, by: >)
        XCTAssertEqual(result, expectedIndex)

        value = 0
        expectedIndex = 15
        result = array.findInsertionIndex(for: value, options: .lastEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 10
        result = array.reversed().findInsertionIndex(for: value, options: .lastEqual, by: >)
        XCTAssertEqual(result, expectedIndex)
    }

    func testStart() {
        let value = -100
        var expectedIndex = 0
        var result = array.findInsertionIndex(for: value, options: .anyEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 22
        result = array.reversed().findInsertionIndex(for: value, options: .anyEqual, by: >)
        XCTAssertEqual(result, expectedIndex)
    }

    func testEnd() {
        let value = 100
        var expectedIndex = 22
        var result = array.findInsertionIndex(for: value, options: .anyEqual, by: <)
        XCTAssertEqual(result, expectedIndex)

        expectedIndex = 0
        result = array.reversed().findInsertionIndex(for: value, options: .anyEqual, by: >)
        XCTAssertEqual(result, expectedIndex)
    }
}
