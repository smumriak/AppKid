//
//  LinuxMain.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29/1/20.
//

import XCTest

import testTests

var tests = [XCTestCaseEntry]()
tests += testTests.allTests()
XCTMain(tests)
