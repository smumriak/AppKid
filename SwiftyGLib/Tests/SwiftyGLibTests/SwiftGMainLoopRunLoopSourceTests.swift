//
//  SwiftGMainLoopRunLoopSourceTests.swift
//  SwiftyGLib
//
//  Created by Serhii Mumriak on 20.11.2021.
//

import XCTest
@testable import SwiftyGLib
import CGlib
import TinyFoundation

final class SwiftGMainLoopRunLoopSourceTests: XCTestCase {
    var timerTickCount = 0

    func testGMainContextRunLoopSorceTimer() throws {
        let mainContext = SwiftGMainContext(handlePointer: RetainablePointer(withRetained: g_main_context_default()))
        let source = try XCTUnwrap(SwiftGMainLoopRunLoopSource(context: mainContext))
        defer {
            source.invalidate()
        }

        _ = g_timeout_add(0, { userData in
            guard let userData = userData else {
                return 0
            }

            let `self` = Unmanaged<SwiftGMainLoopRunLoopSourceTests>.fromOpaque(userData).takeUnretainedValue()

            self.timerTickCount += 1

            return self.timerTickCount < 5 ? 1 : 0
        }, Unmanaged<SwiftGMainLoopRunLoopSourceTests>.passUnretained(self).toOpaque())

        source.schedule(in: .current, forMode: .common)

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))

        XCTAssertEqual(timerTickCount, 5)
    }
}
