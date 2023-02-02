//
//  RunLoopTests.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 31.01.2023
//

import XCTest
@testable import TinyFoundation

final class MainThreadRunLoopTests: XCTestCase {
    var runLoop: RunLoop1!

    override func setUp() {
        super.setUp()

        runLoop = .current
    }

    override func tearDown() {
        RunLoop1.clearRunLoop(Thread.current)

        super.tearDown()
    }

    func testTestedIsMain() throws {
        XCTAssertIdentical(RunLoop1.main, runLoop)
    }
}

final class BackgroundThreadRunLoopTests: XCTestCase {
    var runLoop: RunLoop1!
    var thread: Thread!
    var testBlock: (() throws -> ())?
    var expectation: XCTestExpectation!
    var error: Error?

    override func setUp() {
        super.setUp()

        thread = Thread { [unowned self] in
            do {
                try testBlock?()
            } catch {
                self.error = error
            }

            expectation.fulfill()
        }

        runLoop = RunLoop1.getRunLoop(thread)
        expectation = XCTestExpectation()
    }

    override func tearDown() {
        testBlock = nil
        expectation = nil
        RunLoop1.clearRunLoop(thread)
        thread = nil

        super.tearDown()
    }

    func testTestedIsNotMain() throws {
        thread.start()
        wait(for: [expectation], timeout: 5)
        XCTAssertNotIdentical(RunLoop1.main, runLoop)
    }
}
