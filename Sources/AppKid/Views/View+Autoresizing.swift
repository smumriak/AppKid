//
//  View+Autoresizing.swift
//  AppKid
//
//  Created by Serhii Mumriak on 26.04.2020.
//

import Foundation

public extension View {
    struct AutoresizingMask: OptionSet {
        public typealias RawValue = UInt
        public var rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static var none = Self([])
        public static var leftMargin = Self(rawValue: 1 << 0)
        public static var width = Self(rawValue: 1 << 1)
        public static var rightMargin = Self(rawValue: 1 << 2)
        public static var topMargin = Self(rawValue: 1 << 3)
        public static var height = Self(rawValue: 1 << 4)
        public static var bottomMargin = Self(rawValue: 1 << 5)
    }
}
