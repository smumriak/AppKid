//
//  CGSize+Arithmetic.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#else
    import Foundation
#endif

public extension CGSize {
    static let nan: CGSize = CGSize(width: CGFloat.nan, height: CGFloat.nan)
}

public extension CGSize {
    @_transparent
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    @_transparent
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    @_transparent
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    @_transparent
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}

public extension CGSize {
    @_transparent
    static func + (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width + rhs.x, height: lhs.height + rhs.y)
    }

    @_transparent
    static func - (lhs: CGSize, rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width - rhs.x, height: lhs.height - rhs.y)
    }
}
