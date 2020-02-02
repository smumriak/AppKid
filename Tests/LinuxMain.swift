import XCTest

import testTests

var tests = [XCTestCaseEntry]()
tests += testTests.allTests()
XCTMain(tests)
