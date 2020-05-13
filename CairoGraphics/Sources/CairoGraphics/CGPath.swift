//
//  CGPath.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import CCairo

open class CGPath {
    internal var _pathPointer: CNonReferablePointer<cairo_path_t>
    internal var _path: UnsafeMutablePointer<cairo_path_t> {
        get {
            return _pathPointer.pointer
        }
        set {
            _pathPointer = CNonReferablePointer(with: newValue)
        }
    }
    
    internal init?(currentPath context: UnsafeMutablePointer<cairo_t>) {
        if let path = cairo_copy_path(context) {
            _pathPointer = CNonReferablePointer(with: path)
        } else {
            return nil
        }
    }
}
