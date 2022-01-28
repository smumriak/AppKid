//
//  Set+Operators.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 25.01.2022.
//

import Foundation

public extension Set {
    @_transparent
    static func + (lhs: Self, rhs: Self) -> Self {
        return lhs.union(rhs)
    }

    @_transparent
    static func + (lhs: Self, rhs: Element) -> Self {
        return lhs.union([rhs])
    }

    @_transparent
    static func + <T: Sequence>(lhs: Self, rhs: T) -> Self where T.Element == Self.Element {
        return lhs.union(rhs)
    }

    @_transparent
    static func - (lhs: Self, rhs: Self) -> Self {
        return lhs.subtracting(rhs)
    }

    @_transparent
    static func - (lhs: Self, rhs: Element) -> Self {
        return lhs.subtracting([rhs])
    }

    @_transparent
    static func - <T: Sequence>(lhs: Self, rhs: T) -> Self where T.Element == Self.Element {
        return lhs.subtracting(rhs)
    }
}
