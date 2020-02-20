//
//  CGContextState.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 9/2/20.
//

import Foundation
import CCairo

internal class CGContextState {
    var alpha: CGFloat = .zero
    
    fileprivate var defaultPatternPointer: CReferablePointer<cairo_pattern_t> = CReferablePointer(with: cairo_pattern_create_rgba(0.0, 0.0, 0.0, 1.0))
    var defaultPattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return defaultPatternPointer.pointer
        }
        set {
            defaultPatternPointer = CReferablePointer(with: newValue)
        }
    }

    var fillColor: CGColor = .clear {
        didSet {
            fillPatternPointer = fillColor.cairoPattern
        }
    }
    fileprivate lazy var fillPatternPointer: CReferablePointer<cairo_pattern_t> = defaultPatternPointer
    fileprivate(set) var fillPattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return fillPatternPointer.pointer
        }
        set {
            fillPatternPointer = CReferablePointer(with: newValue)
        }
    }
    
    var strokeColor: CGColor = .clear {
        didSet {
            strokePatternPointer = strokeColor.cairoPattern
        }
    }
    fileprivate lazy var strokePatternPointer: CReferablePointer<cairo_pattern_t> = defaultPatternPointer
    fileprivate(set) var strokePattern: UnsafeMutablePointer<cairo_pattern_t> {
        get {
            return strokePatternPointer.pointer
        }
        set {
            strokePatternPointer = CReferablePointer(with: newValue)
        }
    }
    
    var shadowColor: CGColor = .clear
    var shadowOffset: CGSize = .zero
    var shadowRadius: CGFloat = .zero
}


