//
//  CGPath.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import CCairo
import TinyFoundation

open class CGPath {
    internal var _pathPointer: CopyablePointer<cairo_path_t>
    internal var _path: UnsafeMutablePointer<cairo_path_t> {
        get {
            return _pathPointer.pointer
        }
        set {
            _pathPointer = CopyablePointer(with: newValue)
        }
    }
    
    internal init?(from context: UnsafeMutablePointer<cairo_t>) {
        if let path = cairo_copy_path(context) {
            _pathPointer = CopyablePointer(with: path)
        } else {
            return nil
        }
    }
}
