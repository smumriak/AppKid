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
    
    fileprivate var defaultPatternPointer: RetainablePointer<cairo_pattern_t> = {
        let cairoPattern = cairo_pattern_create_rgba(0.0, 0.0, 0.0, 1.0)!
        return RetainablePointer(withRetained: cairoPattern)
    }()

    var defaultPattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return defaultPatternPointer.pointer
        }
        set {
            defaultPatternPointer.pointer = newValue
        }
    }

    var fillColor: CGColor = .clear {
        didSet {
            fillPatternPointer = fillColor.cairoPattern
        }
    }

    fileprivate lazy var fillPatternPointer: RetainablePointer<cairo_pattern_t> = defaultPatternPointer
    fileprivate(set) var fillPattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return fillPatternPointer.pointer
        }
        set {
            fillPatternPointer.pointer = newValue
        }
    }
    
    var strokeColor: CGColor = .clear {
        didSet {
            strokePatternPointer = strokeColor.cairoPattern
        }
    }

    fileprivate lazy var strokePatternPointer: RetainablePointer<cairo_pattern_t> = defaultPatternPointer
    fileprivate(set) var strokePattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return strokePatternPointer.pointer
        }
        set {
            strokePatternPointer.pointer = newValue
        }
    }
    
    var shadowColor: CGColor = .clear
    var shadowOffset: CGSize = .zero
    var shadowRadius: CGFloat = .zero
}
