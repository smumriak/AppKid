//
//  XCTestManifests.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 06.09.2020.
//

import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(CGAffineTransformTests.allTests),
        ]
    }
#endif
