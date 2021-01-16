//
//  VkClearColorValue.swift
//  Volcano
//
//  Created by Serhii Mumriak on 14.01.2021.
//

import CVulkan

public typealias VkClearColorValue = CVulkan.VkClearColorValue

public extension VkClearColorValue {
    @inlinable @inline(__always)
    init<T: BinaryFloatingPoint>(red: T, green: T, blue: T, alpha: T = 1.0) {
        self.init(float32: (Float(red), Float(green), Float(blue), Float(alpha)))
    }

    @inlinable @inline(__always)
    init<T: BinaryFloatingPoint>(white: T, alpha: T = 1.0) {
        self.init(red: white, green: white, blue: white, alpha: alpha)
    }

    static let black = VkClearColorValue(white: 0.0)
    static let darkGray = VkClearColorValue(white: 1.0 / 3.0)
    static let lightGray = VkClearColorValue(white: 2.0 / 3.0)
    static let white = VkClearColorValue(white: 1.0)
    static let gray = VkClearColorValue(white: 0.5)

    static let red = VkClearColorValue(red: 1.0, green: 0.0, blue: 0.0)
    static let green = VkClearColorValue(red: 0.0, green: 1.0, blue: 0.0)
    static let blue = VkClearColorValue(red: 0.0, green: 0.0, blue: 1.0)

    static let cyan = VkClearColorValue(red: 0.0, green: 1.0, blue: 1.0)
    static let yellow = VkClearColorValue(red: 1.0, green: 1.0, blue: 0.0)
    static let magenta = VkClearColorValue(red: 1.0, green: 0.0, blue: 1.0)
    
    static let orange = VkClearColorValue(red: 1.0, green: 0.5, blue: 0.0)
    static let purple = VkClearColorValue(red: 0.5, green: 0.0, blue: 0.5)
    static let brown = VkClearColorValue(red: 0.6, green: 0.4, blue: 0.2)

    static let clear = VkClearColorValue(white: 0.0, alpha: 0.0)
}
