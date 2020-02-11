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
    
    var defaultPattern: OpaquePointer = cairo_pattern_create_rgba(0.0, 0.0, 0.0, 1.0) {
        didSet {
            cairo_reference(defaultPattern)
        }
    }
    
    var fillColor: CGColor = .transparent {
        didSet {
            if let fillPattern = fillPattern {
                cairo_pattern_destroy(fillPattern)
            }
            fillPattern = cairo_pattern_create_rgba(Double(fillColor.red), Double(fillColor.green), Double(fillColor.blue), Double(fillColor.alpha))
        }
    }
    var fillPattern: OpaquePointer? = nil
    
    var strokeColor: CGColor = .transparent {
        didSet {
            if let strokePattern = strokePattern {
                cairo_pattern_destroy(strokePattern)
            }
            strokePattern = cairo_pattern_create_rgba(Double(strokeColor.red), Double(strokeColor.green), Double(strokeColor.blue), Double(strokeColor.alpha))
        }
    }
    var strokePattern: OpaquePointer? = nil
    
    var shadowColor: CGColor = .transparent
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
