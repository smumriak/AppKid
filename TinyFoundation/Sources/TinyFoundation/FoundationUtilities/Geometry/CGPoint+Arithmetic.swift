//
//  CGPoint+Arithmetic.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 27.04.2020.
//

import Foundation

public extension CGPoint {
    static let nan: CGPoint = CGPoint(x: CGFloat.nan, y: CGFloat.nan)
}

public extension CGPoint {
    @inlinable @inline(__always)
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    @inlinable @inline(__always)
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    @inlinable @inline(__always)
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    @inlinable @inline(__always)
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

public extension CGPoint {
    @inlinable @inline(__always)
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    @inlinable @inline(__always)
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
}
