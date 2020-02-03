//
//  XCTestManifests.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29/1/20.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(testTests.allTests),
    ]
}
#endif
