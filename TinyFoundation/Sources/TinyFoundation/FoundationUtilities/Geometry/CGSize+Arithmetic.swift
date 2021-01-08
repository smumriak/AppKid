//
//  CGSize+Arithmetic.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation

public extension CGSize {
    static let nan: CGSize = CGSize(width: CGFloat.nan, height: CGFloat.nan)
}

public extension CGSize {
    @inlinable @inline(__always)
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    @inlinable @inline(__always)
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    @inlinable @inline(__always)
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    @inlinable @inline(__always)
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}

public extension CGSize {
    @inlinable @inline(__always)
    static func + (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width + rhs.x, height: lhs.height + rhs.y)
    }

    @inlinable @inline(__always)
    static func - (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width - rhs.x, height: lhs.height - rhs.y)
    }
}
