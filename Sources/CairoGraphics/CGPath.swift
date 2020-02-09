//
//  CGPath.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 8/2/20.
//

import Foundation
import CCairo

open class CGPath {
    internal var _path: UnsafeMutablePointer<cairo_path_t>
    
    deinit {
        cairo_path_destroy(_path)
    }
    
    internal init?(currentPath context: OpaquePointer) {
        if let path = cairo_copy_path(context) {
            _path = path
        } else {
            return nil
        }
    }
}
