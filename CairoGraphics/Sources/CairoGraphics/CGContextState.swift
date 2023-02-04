//
//  CGContextState.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 09.02.2020.
//

import Foundation
import CCairo
import TinyFoundation

internal final class CGContextState {
    var alpha: CGFloat = .zero

    var fillColor: CGColor = .clear {
        didSet {
            fillPattern = fillColor.cairoPattern.pointer
        }
    }

    @Retainable
    internal var fillPattern: UnsafeMutablePointer<cairo_pattern_t> = cairo_pattern_create_rgba(0.0, 0.0, 0.0, 1.0)!

    var strokeColor: CGColor = .clear {
        didSet {
            strokePattern = strokeColor.cairoPattern.pointer
        }
    }

    @Retainable
    internal var strokePattern: UnsafeMutablePointer<cairo_pattern_t> = cairo_pattern_create_rgba(0.0, 0.0, 0.0, 1.0)!
    
    var shadowColor: CGColor = .clear
    var shadowOffset: CGSize = .zero
    var shadowRadius: CGFloat = .zero
}
