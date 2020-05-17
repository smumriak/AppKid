//
//  CGContextState.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 09.02.2020.
//

import Foundation
import CCairo
import TinyFoundation

internal class CGContextState {
    var alpha: CGFloat = .zero
    
    fileprivate var defaultPatternPointer: ReferablePointer<cairo_pattern_t> = ReferablePointer(with: cairo_pattern_create_rgba(0.0, 0.0, 0.0, 1.0))
    var defaultPattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return defaultPatternPointer.pointer
        }
        set {
            defaultPatternPointer = ReferablePointer(with: newValue)
        }
    }

    var fillColor: CGColor = .clear {
        didSet {
            fillPatternPointer = fillColor.cairoPattern
        }
    }
    fileprivate lazy var fillPatternPointer: ReferablePointer<cairo_pattern_t> = defaultPatternPointer
    fileprivate(set) var fillPattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return fillPatternPointer.pointer
        }
        set {
            fillPatternPointer = ReferablePointer(with: newValue)
        }
    }
    
    var strokeColor: CGColor = .clear {
        didSet {
            strokePatternPointer = strokeColor.cairoPattern
        }
    }
    fileprivate lazy var strokePatternPointer: ReferablePointer<cairo_pattern_t> = defaultPatternPointer
    fileprivate(set) var strokePattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return strokePatternPointer.pointer
        }
        set {
            strokePatternPointer = ReferablePointer(with: newValue)
        }
    }
    
    var shadowColor: CGColor = .clear
    var shadowOffset: CGSize = .zero
    var shadowRadius: CGFloat = .zero
}


