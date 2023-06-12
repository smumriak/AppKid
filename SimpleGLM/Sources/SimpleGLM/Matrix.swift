//
//  Matrix.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 04.09.2020.
//

import Foundation

public typealias mat2s = cglm.mat2s
public typealias mat3s = cglm.mat3s
public typealias mat4s = cglm.mat4s

public protocol Matrix<RawValue>: Hashable {
    associatedtype RawValue
    associatedtype ColumnType
    associatedtype ColumnsValue

    var raw: RawValue { get }
    var col: ColumnsValue { get }
    static var columnSize: Int { get }

    static var identity: Self { get }
    static var zero: Self { get }
    
    var isIdentity: Bool { get }
    var inversed: Self { get }

    static var inverse_f: (Self) -> (Self) { get }
    static var mul_f: (Self, Self) -> (Self) { get }
    static var mulv_f: (Self, ColumnType) -> (ColumnType) { get }
    static var scale_f: (Self, Float) -> (Self) { get }
    static var determinant_f: (Self) -> Float { get }
}

public protocol AffineTransformableMatrix: Matrix {
    associatedtype TranslationVector
    associatedtype ScaleVector

    static var affineTranslateByVector_f: (Self, TranslationVector) -> (Self) { get }
    static var initUsingTranslationVector_f: (TranslationVector) -> (Self) { get }
    static var affineScaleByVector_f: (Self, ScaleVector) -> (Self) { get }
    static var initUsingScaleVector_f: (ScaleVector) -> (Self) { get }
}

public extension Matrix {
    @_transparent
    var isIdentity: Bool { self == Self.identity }

    @_transparent
    var inversed: Self { isIdentity ? self : Self.inverse_f(self) }

    @_transparent
    mutating func inverse() { self = inversed }

    @_transparent
    static func * (_ lhs: Self, _ rhs: Self) -> Self { mul_f(lhs, rhs) }

    @_transparent
    static func * (_ lhs: Self, _ rhs: ColumnType) -> ColumnType { mulv_f(lhs, rhs) }

    @_transparent
    static func * <T: BinaryFloatingPoint>(_ lhs: Self, _ rhs: T) -> Self { scale_f(lhs, Float(rhs)) }

    @_transparent
    var determinant: Float { Self.determinant_f(self) }
}

public extension AffineTransformableMatrix {
    @_transparent
    init(translationVector: TranslationVector) { self = Self.initUsingTranslationVector_f(translationVector) }

    @_transparent
    func translated(by vector: TranslationVector) -> Self { Self.affineTranslateByVector_f(self, vector) }

    @_transparent
    mutating func translate(by vector: TranslationVector) { self = Self.affineTranslateByVector_f(self, vector) }

    @_transparent
    init(scaleVector: ScaleVector) { self = Self.initUsingScaleVector_f(scaleVector) }

    @_transparent
    func scaled(by vector: ScaleVector) -> Self { Self.affineScaleByVector_f(self, vector) }

    @_transparent
    mutating func scale(by vector: ScaleVector) { self = Self.affineScaleByVector_f(self, vector) }
}

public extension Matrix where ColumnsValue == (vec2s, vec2s) {
    @_transparent
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.col == rhs.col }
}

public extension Matrix where ColumnsValue == (vec3s, vec3s, vec3s) {
    @_transparent
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.col == rhs.col }
}

public extension Matrix where ColumnsValue == (vec4s, vec4s, vec4s, vec4s) {
    @_transparent
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.col == rhs.col }
}

extension mat2s: Matrix {
    public static let columnSize: Int = 2
    
    public static let identity: Self = glms_mat2_identity()
    public static let zero: Self = glms_mat2_zero()

    public static let inverse_f = glms_mat2_inv
    public static let mul_f = glms_mat2_mul
    public static let mulv_f = glms_mat2_mulv
    public static let scale_f = glms_mat2_scale
    public static let determinant_f = glms_mat2_det

    public func hash(into hasher: inout Hasher) {
        hasher.combine(m00)
        hasher.combine(m01)
        hasher.combine(m10)
        hasher.combine(m11)
    }
}

extension mat3s: AffineTransformableMatrix {
    public static let columnSize: Int = 3

    public static let identity: Self = glms_mat3_identity()
    public static let zero: Self = glms_mat3_zero()

    public static let inverse_f = glms_mat3_inv
    public static let mul_f = glms_mat3_mul
    public static let mulv_f = glms_mat3_mulv
    public static let scale_f = glms_mat3_scale
    public static let determinant_f = glms_mat3_det
    public static let affineTranslateByVector_f = glms_translate2d
    public static let initUsingTranslationVector_f = glms_translate2d_make
    public static let affineScaleByVector_f = glms_scale2d
    public static let initUsingScaleVector_f = glms_scale2d_make

    public func hash(into hasher: inout Hasher) {
        hasher.combine(m00)
        hasher.combine(m01)
        hasher.combine(m02)
        hasher.combine(m10)
        hasher.combine(m11)
        hasher.combine(m12)
        hasher.combine(m20)
        hasher.combine(m21)
        hasher.combine(m22)
    }

    @_transparent
    public init<T: BinaryFloatingPoint>(rotationAngle angle: T) { self = glms_rotate2d_make(Float(angle)) }

    @_transparent
    public func rotated<T: BinaryFloatingPoint>(by angle: T) -> Self { glms_rotate2d(self, Float(angle)) }

    @_transparent
    public mutating func rotate<T: BinaryFloatingPoint>(by angle: T) { self = glms_rotate2d(self, Float(angle)) }
}

extension mat4s: AffineTransformableMatrix {
    public static let columnSize: Int = 4

    public static let identity: Self = glms_mat4_identity()
    public static let zero: Self = glms_mat4_zero()

    public static let inverse_f = glms_mat4_inv
    public static let mul_f = glms_mat4_mul
    public static let mulv_f = glms_mat4_mulv
    public static let scale_f = glms_mat4_scale
    public static let determinant_f = glms_mat4_det
    public static let affineTranslateByVector_f = glms_translate
    public static let initUsingTranslationVector_f = glms_translate_make
    public static let affineScaleByVector_f = glms_scale
    public static let initUsingScaleVector_f = glms_scale_make

    public func hash(into hasher: inout Hasher) {
        hasher.combine(m00)
        hasher.combine(m01)
        hasher.combine(m02)
        hasher.combine(m03)
        hasher.combine(m10)
        hasher.combine(m11)
        hasher.combine(m12)
        hasher.combine(m13)
        hasher.combine(m20)
        hasher.combine(m21)
        hasher.combine(m22)
        hasher.combine(m23)
        hasher.combine(m30)
        hasher.combine(m31)
        hasher.combine(m32)
        hasher.combine(m33)
    }

    @_transparent
    public init<T: BinaryFloatingPoint>(m00: T, m01: T, m02: T, m03: T,
                                        m10: T, m11: T, m12: T, m13: T,
                                        m20: T, m21: T, m22: T, m23: T,
                                        m30: T, m31: T, m32: T, m33: T) {
        self.init()
        
        self.m00 = Float(m00)
        self.m01 = Float(m01)
        self.m02 = Float(m02)
        self.m03 = Float(m03)

        self.m10 = Float(m10)
        self.m11 = Float(m11)
        self.m12 = Float(m12)
        self.m13 = Float(m13)

        self.m20 = Float(m20)
        self.m21 = Float(m21)
        self.m22 = Float(m22)
        self.m23 = Float(m23)

        self.m30 = Float(m30)
        self.m31 = Float(m31)
        self.m32 = Float(m32)
        self.m33 = Float(m33)
    }

    @_transparent
    public init<T: BinaryFloatingPoint>(rotationAngle angle: T, axis: vec3s) { self = glms_rotate_make(Float(angle), axis) }

    @_transparent
    public static func perspective<T: BinaryFloatingPoint>(fieldOfViewY: T, aspectRatio: T, near: T, far: T) -> Self {
        glms_perspective(Float(fieldOfViewY), Float(aspectRatio), Float(near), Float(far))
    }

    @_transparent
    public static func orthographic<T: BinaryFloatingPoint>(left: T, right: T, bottom: T, top: T, near: T, far: T) -> Self {
        glms_ortho(Float(left), Float(right), Float(bottom), Float(top), Float(near), Float(far))
    }

    @_transparent
    public static func lootAt(eye: vec3s, center: vec3s, up: vec3s) -> Self {
        glms_lookat(eye, center, up)
    }

    @_transparent
    public func rotated<T: BinaryFloatingPoint>(by angle: T, axis: vec3s) -> Self { glms_rotate(self, Float(angle), axis) }

    @_transparent
    public mutating func rotate<T: BinaryFloatingPoint>(by angle: T, axis: vec3s) { self = glms_rotate(self, Float(angle), axis) }
}

extension mat2s: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        mat2s: 
        | m00: \(m00) | m01: \(m01) |
        | m10: \(m10) | m11: \(m11) |
        """
    }
}

extension mat3s: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        mat3s: 
        | m00: \(m00) | m01: \(m01) | m02: \(m02) |
        | m10: \(m10) | m11: \(m11) | m12: \(m12) |
        | m20: \(m20) | m21: \(m21) | m22: \(m22) |
        """
    }
}

extension mat4s: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        mat4s: 
        | m00: \(m00) | m01: \(m01) | m02: \(m02) | m02: \(m03) |
        | m10: \(m10) | m11: \(m11) | m12: \(m12) | m12: \(m13) |
        | m20: \(m20) | m21: \(m21) | m22: \(m22) | m22: \(m23) |
        | m30: \(m30) | m21: \(m31) | m22: \(m32) | m22: \(m33) |
        """
    }
}
