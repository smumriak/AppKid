//
//  CALayerKVCTests.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 25.11.2021.
//

import XCTest
@testable import ContentAnimation
import TinyFoundation

final class CALayerKVCTests: XCTestCase {
    func testSimpleKVC() {
        let layer = CALayer()
        layer.setValue(CGPoint(x: 10.0, y: 10.0), forKeyPath: "bounds.origin")
        layer.setValue(CGFloat(42), forKeyPath: "bounds.size.width")

        XCTAssertEqual(layer.bounds.origin.x, 10.0, accuracy: .ulpOfOne)
        XCTAssertEqual(layer.bounds.size.width, 42.0, accuracy: .ulpOfOne)
    }
}
