import XCTest

import archiveTests

var tests = [XCTestCaseEntry]()
tests += archiveTests.allTests()
XCTMain(tests)
