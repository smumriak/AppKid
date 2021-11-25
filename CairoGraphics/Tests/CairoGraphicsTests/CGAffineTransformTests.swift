//
//  CGAffineTransformTests.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 06.09.2020.
//

import XCTest
import Foundation
@testable import CairoGraphics
import SimpleGLM

// palkovnik:cglm supports floats only for now and most operations have really low precision. at least the API i used for things. aparently there are some functions that have another implementation with higher precision
let accuracy: CGFloat = 0.0001

typealias TestedAffineTransform = CGAffineTransform_cglm_WorkInProgress
typealias ControlAffineTransform = CGAffineTransform_cairo

final class CGAffineTransformTests: XCTestCase {
    func equalityCheck(_ testTransform: TestedAffineTransform, _ controlTransform: ControlAffineTransform) throws {
        XCTAssertEqual(testTransform.a, controlTransform.a, accuracy: accuracy)
        XCTAssertEqual(testTransform.b, controlTransform.b, accuracy: accuracy)
        XCTAssertEqual(testTransform.c, controlTransform.c, accuracy: accuracy)
        XCTAssertEqual(testTransform.d, controlTransform.d, accuracy: accuracy)
        XCTAssertEqual(testTransform.tx, controlTransform.tx, accuracy: accuracy)
        XCTAssertEqual(testTransform.ty, controlTransform.ty, accuracy: accuracy)

        XCTAssertEqual(testTransform._matrix.xx, controlTransform._matrix.xx, accuracy: Double(accuracy))
        XCTAssertEqual(testTransform._matrix.yx, controlTransform._matrix.yx, accuracy: Double(accuracy))
        XCTAssertEqual(testTransform._matrix.xy, controlTransform._matrix.xy, accuracy: Double(accuracy))
        XCTAssertEqual(testTransform._matrix.yy, controlTransform._matrix.yy, accuracy: Double(accuracy))
        XCTAssertEqual(testTransform._matrix.x0, controlTransform._matrix.x0, accuracy: Double(accuracy))
        XCTAssertEqual(testTransform._matrix.y0, controlTransform._matrix.y0, accuracy: Double(accuracy))
    }

    func testIdentity() throws {
        let testTransform = TestedAffineTransform()
        let controlTransform = ControlAffineTransform()

        try equalityCheck(testTransform, controlTransform)
    }

    func testRotation() throws {
        var testTransform = TestedAffineTransform().rotated(by: .pi / 4)
        var controlTransform = ControlAffineTransform().rotated(by: .pi / 4)

        try equalityCheck(testTransform, controlTransform)

        try equalityCheck(testTransform, controlTransform)

        testTransform = testTransform.rotated(by: .pi / 4)
        controlTransform = controlTransform.rotated(by: .pi / 4)

        try equalityCheck(testTransform, controlTransform)
    }

    func testScale() throws {
        var testTransform = TestedAffineTransform().scaledBy(x: 2.3, y: 7.1)
        var controlTransform = ControlAffineTransform().scaledBy(x: 2.3, y: 7.1)

        try equalityCheck(testTransform, controlTransform)

        testTransform = testTransform.scaledBy(x: 2.3, y: 7.1)
        controlTransform = controlTransform.scaledBy(x: 2.3, y: 7.1)

        try equalityCheck(testTransform, controlTransform)

        testTransform = testTransform.scaledBy(x: 1 / 5, y: 1 / 22)
        controlTransform = controlTransform.scaledBy(x: 1 / 5, y: 1 / 22)

        try equalityCheck(testTransform, controlTransform)
    }

    func testTranslate() throws {
        var testTransform = TestedAffineTransform().translatedBy(x: 2.3, y: 7.1)
        var controlTransform = ControlAffineTransform().translatedBy(x: 2.3, y: 7.1)

        try equalityCheck(testTransform, controlTransform)

        testTransform = testTransform.translatedBy(x: -500, y: -2 / 3)
        controlTransform = controlTransform.translatedBy(x: -500, y: -2 / 3)

        try equalityCheck(testTransform, controlTransform)
    }

    func testAll() throws {
        var testTransform = TestedAffineTransform()
        var controlTransform = ControlAffineTransform()

        testTransform = testTransform.rotated(by: .pi / 4)
        controlTransform = controlTransform.rotated(by: .pi / 4)

        try equalityCheck(testTransform, controlTransform)

        testTransform = testTransform.scaledBy(x: 2.3, y: 7.1)
        controlTransform = controlTransform.scaledBy(x: 2.3, y: 7.1)

        try equalityCheck(testTransform, controlTransform)

        testTransform = testTransform.translatedBy(x: -500, y: -2 / 3)
        controlTransform = controlTransform.translatedBy(x: -500, y: -2 / 3)

        try equalityCheck(testTransform, controlTransform)
    }

    func testInvert() throws {
        var testTransform = TestedAffineTransform()
        var controlTransform = ControlAffineTransform()

        testTransform = testTransform.inverted()
        controlTransform = controlTransform.inverted()

        try equalityCheck(testTransform, controlTransform)
    }

    func testConversions() throws {
        let rotation = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        var test = mat4s.identity

        test.m00 = Float(rotation.a)
        test.m01 = Float(rotation.b)
        test.m10 = Float(rotation.c)
        test.m11 = Float(rotation.d)
        test.m20 = Float(rotation.tx)
        test.m21 = Float(rotation.ty)

        let control = mat4s(rotationAngle: CGFloat.pi / 4, axis: vec3s(x: 0.0, y: 0.0, z: 1.0))

        try equalityCheck(test, control)
    }
}
