//
//  CATransform3D.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 22.12.2020.
//

import Foundation
import CairoGraphics
import SimpleGLM
import TinyFoundation

#if os(macOS)
    import struct CairoGraphics.CGAffineTransform
#endif

// smumriak:TODO:Implement this thing using mat4 from cglm

public struct CATransform3D {
    public var m11: CGFloat
    public var m12: CGFloat
    public var m13: CGFloat
    public var m14: CGFloat
       
    public var m21: CGFloat
    public var m22: CGFloat
    public var m23: CGFloat
    public var m24: CGFloat
       
    public var m31: CGFloat
    public var m32: CGFloat
    public var m33: CGFloat
    public var m34: CGFloat
       
    public var m41: CGFloat
    public var m42: CGFloat
    public var m43: CGFloat
    public var m44: CGFloat

    public init(m11: CGFloat, m12: CGFloat, m13: CGFloat, m14: CGFloat,
                m21: CGFloat, m22: CGFloat, m23: CGFloat, m24: CGFloat,
                m31: CGFloat, m32: CGFloat, m33: CGFloat, m34: CGFloat,
                m41: CGFloat, m42: CGFloat, m43: CGFloat, m44: CGFloat) {
        self.m11 = m11
        self.m12 = m12
        self.m13 = m13
        self.m14 = m14

        self.m21 = m21
        self.m22 = m22
        self.m23 = m23
        self.m24 = m24

        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
        self.m34 = m34

        self.m41 = m41
        self.m42 = m42
        self.m43 = m43
        self.m44 = m44
    }
}

public extension CATransform3D {
    static let identity = CATransform3D(m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0,
                                        m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0,
                                        m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0,
                                        m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)

    static let zero = CATransform3D(m11: 0.0, m12: 0.0, m13: 0.0, m14: 0.0,
                                    m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0,
                                    m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0,
                                    m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0)

    init() {
        self = .identity
    }

    var isIdentity: Bool {
        self == .identity
    }

    init(translationX tx: CGFloat, y ty: CGFloat, z tz: CGFloat) {
        self.init(m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0,
                  m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0,
                  m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0,
                  m41: tx, m42: ty, m43: tz, m44: 1.0)
    }

    init(scaleX sx: CGFloat, y sy: CGFloat, z sz: CGFloat) {
        self.init(m11: sx, m12: 0.0, m13: 0.0, m14: 0.0,
                  m21: 0.0, m22: sy, m23: 0.0, m24: 0.0,
                  m31: 0.0, m32: 0.0, m33: sz, m34: 0.0,
                  m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)
    }

    // init(rotationAngle angle: CGFloat, x sx: CGFloat, y sy: CGFloat, z sz: CGFloat) {
    //     self.init(m11: sx, m12: 0.0, m13: 0.0, m14: 0.0,
    //               m21: 0.0, m22: sy, m23: 0.0, m24: 0.0,
    //               m31: 0.0, m32: 0.0, m33: sz, m34: 0.0,
    //               m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)
    // }
}

extension CATransform3D: Equatable {
    public static func == (_ lhs: CATransform3D, _ rhs: CATransform3D) -> Bool {
        lhs.m11 == rhs.m11 &&
            lhs.m12 == rhs.m12 &&
            lhs.m13 == rhs.m13 &&
            lhs.m14 == rhs.m14 &&
            lhs.m21 == rhs.m21 &&
            lhs.m22 == rhs.m22 &&
            lhs.m23 == rhs.m23 &&
            lhs.m24 == rhs.m24 &&
            lhs.m31 == rhs.m31 &&
            lhs.m32 == rhs.m32 &&
            lhs.m33 == rhs.m33 &&
            lhs.m34 == rhs.m34 &&
            lhs.m41 == rhs.m41 &&
            lhs.m42 == rhs.m42 &&
            lhs.m43 == rhs.m43 &&
            lhs.m44 == rhs.m44
    }
}

public extension CGAffineTransform {
    var transform3D: CATransform3D {
        var result = CATransform3D.identity

        result.m11 = a
        result.m12 = b
        result.m21 = c
        result.m22 = d
        result.m31 = tx
        result.m32 = ty

        return result
    }

    var mat4: mat4s {
        var result = mat4s.identity

        result.m00 = Float(a)
        result.m01 = Float(b)
        result.m10 = Float(c)
        result.m11 = Float(d)
        result.m20 = Float(tx)
        result.m21 = Float(ty)

        return result
    }
}

public extension CATransform3D {
    var affineTransform: CGAffineTransform {
        CGAffineTransform(a: m11, b: m12, c: m21, d: m22, tx: m31, ty: m32)
    }

    var mat4: mat4s {
        mat4s(m00: m11, m01: m12, m02: m13, m03: m14,
              m10: m21, m11: m22, m12: m23, m13: m24,
              m20: m31, m21: m32, m22: m33, m23: m34,
              m30: m41, m31: m42, m32: m43, m33: m44)
    }
}

extension CATransform3D: PublicInitializable {}

extension CATransform3D: KeyValueCodable {
    public func value(forKey key: String) -> Any? {
        switch key {
            case "rotation.x": return nil
            case "rotation.y": return nil
            case "rotation.z": return nil
            case "rotation": return nil
            case "scale.x": return m11
            case "scale.y": return m22
            case "scale.z": return m33
            case "scale": return (m11 + m22 + m33) / 3.0
            case "translation.x": return m41
            case "translation.y": return m42
            case "translation.z": return m43
            case "translation": return CGSize(width: m41, height: m42)
            default: return nil
        }
    }

    public func value(forKeyPath keyPath: String) -> Any? {
        return value(forKey: keyPath)
    }

    public mutating func setValue(_ value: Any?, forKey key: String) {
        switch key {
            case "rotation.x": break
            case "rotation.y": break
            case "rotation.z": break
            case "rotation": break
            case "scale.x": break
            case "scale.y": break
            case "scale.z": break
            case "scale": break
            case "translation.x": break
            case "translation.y": break
            case "translation.z": break
            case "translation": break
            default: break
        }
    }

    public mutating func setValue(_ value: Any?, forKeyPath keyPath: String) {
        self.setValue(value, forKey: keyPath)
    }
}
