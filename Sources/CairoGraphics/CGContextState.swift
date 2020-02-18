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
    
    var defaultPattern: UnsafeMutablePointer<cairo_pattern_t> = cairo_pattern_create_rgba(0.0, 0.0, 0.0, 1.0) {
        willSet {
            defaultPattern.release()
        }
        didSet {
            defaultPattern.retain()
        }
    }
    
    var fillColor: CGColor = .clear {
        didSet {
            if let fillPattern = fillPattern {
                cairo_pattern_destroy(fillPattern)
            }
            fillPattern = cairo_pattern_create_rgba(Double(fillColor.red), Double(fillColor.green), Double(fillColor.blue), Double(fillColor.alpha))
        }
    }
    var fillPattern: UnsafeMutablePointer<cairo_pattern_t>? = nil {
        willSet {
            if let fillPattern = fillPattern {
                fillPattern.release()
            }
        }
        didSet {
            if let fillPattern = fillPattern {
                fillPattern.retain()
            }
        }
    }
    
    var strokeColor: CGColor = .clear {
        didSet {
            let pattern = cairo_pattern_create_rgba(Double(strokeColor.red), Double(strokeColor.green), Double(strokeColor.blue), Double(strokeColor.alpha))
            strokePattern = pattern
            pattern?.release()
        }
    }
    var strokePattern: UnsafeMutablePointer<cairo_pattern_t>? = nil {
        willSet {
            if let strokePattern = strokePattern {
                strokePattern.release()
            }
        }
        didSet {
            if let strokePattern = strokePattern {
                strokePattern.retain()
            }
        }
    }
    
    var shadowColor: CGColor = .clear
    var shadowOffset: CGSize = .zero
    var shadowRadius: CGFloat = .zero
    
    deinit {
        cairo_pattern_destroy(defaultPattern)
        
        if let fillPattern = fillPattern {
            cairo_pattern_destroy(fillPattern)
        }
        
        if let strokePattern = strokePattern {
            cairo_pattern_destroy(strokePattern)
        }
    }
}


