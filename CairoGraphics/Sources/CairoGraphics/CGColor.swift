//
//  CGColor.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 09.02.2020.
//

import Foundation
import CCairo
import TinyFoundation

// palkovnik:TODO: placeholder because color spaces are hard
public struct CGColor {
    public var red: CGFloat = .zero
    public var green: CGFloat = .zero
    public var blue: CGFloat = .zero
    public var alpha: CGFloat = 1.0

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public init(white: CGFloat, alpha: CGFloat = 1.0) {
        self.red = white
        self.green = white
        self.blue = white
        self.alpha = alpha
    }
}

public extension CGColor {
    static var black = CGColor(white: 0.0)
    static var darkGray = CGColor(white: 1.0 / 3.0)
    static var lightGray = CGColor(white: 2.0 / 3.0)
    static var white = CGColor(white: 1.0)
    static var gray = CGColor(white: 0.5)

    static var red = CGColor(red: 1.0, green: 0.0, blue: 0.0)
    static var green = CGColor(red: 0.0, green: 1.0, blue: 0.0)
    static var blue = CGColor(red: 0.0, green: 0.0, blue: 1.0)

    static var cyan = CGColor(red: 0.0, green: 1.0, blue: 1.0)
    static var yellow = CGColor(red: 1.0, green: 1.0, blue: 0.0)
    static var magenta = CGColor(red: 1.0, green: 0.0, blue: 1.0)
    
    static var orange = CGColor(red: 1.0, green: 0.5, blue: 0.0)
    static var purple = CGColor(red: 0.5, green: 0.0, blue: 0.5)
    static var brown = CGColor(red: 0.6, green: 0.4, blue: 0.2)

    static var clear = CGColor(white: 0.0, alpha: 0.0)
}

extension CGColor: Equatable {
    public static func == (lhs: CGColor, rhs: CGColor) -> Bool {
        return lhs.red == rhs.red &&
            lhs.green == rhs.green &&
            lhs.blue == rhs.blue &&
            lhs.alpha == rhs.alpha
    }
}

public extension CGColor {
    var negative: CGColor {
        return CGColor(red: alpha - red, green: alpha - green, blue: alpha - blue, alpha: alpha)
    }
}

internal extension CGColor {
    var cairoPattern: ReferablePointer<cairo_pattern_t> {
        return ReferablePointer(with: cairo_pattern_create_rgba(Double(red), Double(green), Double(blue), Double(alpha)))
    }
}
