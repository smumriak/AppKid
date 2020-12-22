import XCTest
@testable import SwiftXlib

final class SwiftXlibTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftXlib().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
