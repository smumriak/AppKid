//
//  XCTestManifests.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(testTests.allTests),
    ]
}
#endif
