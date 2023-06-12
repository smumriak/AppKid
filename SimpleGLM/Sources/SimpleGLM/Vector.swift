//
//  Vector.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 04.09.2020.
//

import Foundation

public typealias vec2s = cglm.vec2s
public typealias vec3s = cglm.vec3s
public typealias vec4s = cglm.vec4s

public protocol Vector<RawValue>: Equatable {
    associatedtype RawValue

    var raw: RawValue { get }

    static var dot_f: (Self, Self) -> Float { get }
}

public extension Vector {
    @_transparent
    static func * (_ lhs: Self, rhs: Self) -> Float { dot_f(lhs, rhs) }

    @_transparent
    func dotProduct(_ other: Self) -> Float { self * other }
}

public extension Vector where RawValue == vec2 {
    @_transparent
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.raw == rhs.raw }
}

public extension Vector where RawValue == vec3 {
    @_transparent
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.raw == rhs.raw }
}

public extension Vector where RawValue == vec4 {
    @_transparent
    static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.raw == rhs.raw }
}

extension vec2s: Vector {
    public static let zero = vec2s(x: 0.0, y: 0.0)

    @_transparent
    public init<T: BinaryFloatingPoint>(_ x: T, _ y: T) { self.init(raw: vec2(Float(x), Float(y))) }

    @_transparent
    public init<T: BinaryFloatingPoint>(x: T, y: T) { self.init(raw: vec2(Float(x), Float(y))) }

    @_transparent
    public init<T: BinaryFloatingPoint>(white: T, opacity: T) { self.init(raw: vec2(Float(white), Float(opacity))) }

    public static let dot_f = glms_vec2_dot
}

extension vec3s: Vector {
    public static let zero = vec3s(x: 0.0, y: 0.0, z: 0.0)

    @_transparent
    public init<T: BinaryFloatingPoint>(_ x: T, _ y: T, _ z: T) { self.init(raw: vec3(Float(x), Float(y), Float(z))) }

    @_transparent
    public init<T: BinaryFloatingPoint>(x: T, y: T, z: T) { self.init(raw: vec3(Float(x), Float(y), Float(z))) }
    @_transparent
    public init<T: BinaryFloatingPoint>(r: T, g: T, b: T) { self.init(raw: vec3(Float(r), Float(g), Float(b))) }

    @_transparent
    public var r: Float {
        get { x }
        set { x = newValue }
    }

    @_transparent
    public var g: Float {
        get { y }
        set { y = newValue }
    }

    @_transparent
    public var b: Float {
        get { z }
        set { z = newValue }
    }

    public static let dot_f = glms_vec3_dot
}

extension vec4s: Vector {
    public static let zero = vec4s(x: 0.0, y: 0.0, z: 0.0, w: 0.0)

    @_transparent
    public init<T: BinaryFloatingPoint>(_ x: T, _ y: T, _ z: T, _ w: T) { self.init(raw: vec4(Float(x), Float(y), Float(z), Float(w))) }

    @_transparent
    public init<T: BinaryFloatingPoint>(x: T, y: T, z: T, w: T) { self.init(raw: vec4(Float(x), Float(y), Float(z), Float(w))) }

    @_transparent
    public init<T: BinaryFloatingPoint>(r: T, g: T, b: T, a: T) { self.init(raw: vec4(Float(r), Float(g), Float(b), Float(a))) }

    @_transparent
    public var r: Float {
        get { x }
        set { x = newValue }
    }

    @_transparent
    public var g: Float {
        get { y }
        set { y = newValue }
    }

    @_transparent
    public var b: Float {
        get { z }
        set { z = newValue }
    }

    @_transparent
    public var a: Float {
        get { w }
        set { w = newValue }
    }
    
    @_transparent
    public var rgb: vec3s {
        get { vec3s(r: r, g: g, b: b) }
        set {
            r = newValue.r
            g = newValue.g
            b = newValue.b
        }
    }

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
