//
//  CGColor.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 09.02.2020.
//

import Foundation
import CCairo
import TinyFoundation

// TODO: smumriak: placeholder because color spaces are hard
public struct CGColor {
    public var red: CGFloat = .zero {
        didSet {
            cairoPattern = freshCairoPattern
        }
    }

    public var green: CGFloat = .zero {
        didSet {
            cairoPattern = freshCairoPattern
        }
    }

    public var blue: CGFloat = .zero {
        didSet {
            cairoPattern = freshCairoPattern
        }
    }

    public var alpha: CGFloat = 1.0 {
        didSet {
            cairoPattern = freshCairoPattern
        }
    }

    public init() {
        self = .clear
    }

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        cairoPattern = RetainablePointer(withRetained: cairo_pattern_create_rgba(Double(red), Double(green), Double(blue), Double(alpha))!)
    }

    public init(white: CGFloat, alpha: CGFloat = 1.0) {
        self.red = white
        self.green = white
        self.blue = white
        self.alpha = alpha
        cairoPattern = RetainablePointer(withRetained: cairo_pattern_create_rgba(Double(red), Double(green), Double(blue), Double(alpha))!)
    }



    internal fileprivate(set) var cairoPattern: RetainablePointer<cairo_pattern_t>
}

public extension CGColor {
    static let black = CGColor(white: 0.0)
    static let darkGray = CGColor(white: 1.0 / 3.0)
    static let lightGray = CGColor(white: 2.0 / 3.0)
    static let white = CGColor(white: 1.0)
    static let gray = CGColor(white: 0.5)

    static let red = CGColor(red: 1.0, green: 0.0, blue: 0.0)
    static let green = CGColor(red: 0.0, green: 1.0, blue: 0.0)
    static let blue = CGColor(red: 0.0, green: 0.0, blue: 1.0)

    static let cyan = CGColor(red: 0.0, green: 1.0, blue: 1.0)
    static let yellow = CGColor(red: 1.0, green: 1.0, blue: 0.0)
    static let magenta = CGColor(red: 1.0, green: 0.0, blue: 1.0)
    
    static let orange = CGColor(red: 1.0, green: 0.5, blue: 0.0)
    static let purple = CGColor(red: 0.5, green: 0.0, blue: 0.5)
    static let brown = CGColor(red: 0.6, green: 0.4, blue: 0.2)

    static let clear = CGColor(white: 0.0, alpha: 0.0)
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
    var freshCairoPattern: RetainablePointer<cairo_pattern_t> {
        let cairoPattern = cairo_pattern_create_rgba(Double(red), Double(green), Double(blue), Double(alpha))!
        return RetainablePointer(withRetained: cairoPattern)
    }
}

extension CGColor: PublicInitializable {}

extension CGColor: _ExpressibleByColorLiteral {
      public init(_colorLiteralRed: Float, green: Float, blue: Float, alpha: Float) {
          self.init(red: CGFloat(_colorLiteralRed), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
      }
}