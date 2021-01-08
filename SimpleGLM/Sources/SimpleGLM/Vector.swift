//
//  Vector.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 04.09.2020.
//

import Foundation
import cglm

public protocol Vector: Equatable {
    associatedtype RawValue

    var raw: RawValue { get }

    static var dot_f: (Self, Self) -> Float { get }
}

public extension Vector {
    @inlinable @inline(__always)
    static func * (_ lhs: Self, rhs: Self) -> Float { dot_f(lhs, rhs) }

    @inlinable @inline(__always)
    func dotProduct(_ other: Self) -> Float { self * other }
}

public extension Vector where RawValue == vec2 {
    @inlinable @inline(__always)
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.raw == rhs.raw }
}

public extension Vector where RawValue == vec3 {
    @inlinable @inline(__always)
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.raw == rhs.raw }
}

public extension Vector where RawValue == vec4 {
    @inlinable @inline(__always)
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.raw == rhs.raw }
}

extension vec2s: Vector {
    @inlinable @inline(__always)
    public init<T: BinaryFloatingPoint>(_ x: T, _ y: T) { self.init(raw: vec2(Float(x), Float(y))) }

    @inlinable @inline(__always)
    public init<T: BinaryFloatingPoint>(x: T, y: T) { self.init(raw: vec2(Float(x), Float(y))) }

    public static let dot_f = glms_vec2_dot
}

extension vec3s: Vector {
    @inlinable @inline(__always)
    public init<T: BinaryFloatingPoint>(_ x: T, _ y: T, _ z: T) { self.init(raw: vec3(Float(x), Float(y), Float(z))) }

    @inlinable @inline(__always)
    public init<T: BinaryFloatingPoint>(x: T, y: T, z: T) { self.init(raw: vec3(Float(x), Float(y), Float(z))) }

    public static let dot_f = glms_vec3_dot
}

extension vec4s: Vector {
    @inlinable @inline(__always)
    public init<T: BinaryFloatingPoint>(_ x: T, _ y: T, _ z: T, _ w: T) { self.init(raw: vec4(Float(x), Float(y), Float(z), Float(w))) }

    @inlinable @inline(__always)
    public init<T: BinaryFloatingPoint>(x: T, y: T, z: T, w: T) { self.init(raw: vec4(Float(x), Float(y), Float(z), Float(w))) }

    public static let dot_f = glms_vec4_dot
}

extension vec2s: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        vec2s: 
        | x: \(x) | y: \(y) |
        """
    }
}

extension vec3s: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        vec2s: 
        | x: \(x) | y: \(y) | z: \(z) |
        """
    }
}

extension vec4s: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        vec2s: 
        | x: \(x) | y: \(y) | z: \(z) | w: \(w) |
        """
    }
}