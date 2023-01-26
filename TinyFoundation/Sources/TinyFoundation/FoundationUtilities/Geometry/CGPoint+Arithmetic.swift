//
//  CGPoint+Arithmetic.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 27.04.2020.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#else
    import Foundation
#endif

public extension CGPoint {
    static let nan: CGPoint = CGPoint(x: CGFloat.nan, y: CGFloat.nan)
}

public extension CGPoint {
    @_transparent
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    @_transparent
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    @_transparent
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    @_transparent
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

public extension CGPoint {
    @_transparent
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    @_transparent
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
}
