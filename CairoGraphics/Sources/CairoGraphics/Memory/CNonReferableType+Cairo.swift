//
//  CNonReferableType+Cairo.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 19.02.2020.
//

import Foundation
import CCairo

extension cairo_font_options_t: CNonReferableType {
    public var copyFunc: (UnsafePointer<cairo_font_options_t>?) -> (UnsafeMutablePointer<cairo_font_options_t>?) {
        return cairo_font_options_copy
    }

    public var destroyFunc: (UnsafeMutablePointer<cairo_font_options_t>?) -> () {
        return cairo_font_options_destroy
    }
}

//palkovnik: This is a workaround for some kind of swift bug when compiler does not generate interface for this enum and treats it as a struct
public extension cairo_path_data_type_t {
    static var moveTo = cairo_path_data_type_t(rawValue: 0)
    static var lineTo = cairo_path_data_type_t(rawValue: 1)
    static var curveTo = cairo_path_data_type_t(rawValue: 2)
    static var closePath = cairo_path_data_type_t(rawValue: 3)
}

extension cairo_path_t: CNonReferableType {
    public var copyFunc: (UnsafePointer<cairo_path_t>?) -> (UnsafeMutablePointer<cairo_path_t>?) {
        return {
            guard let path = $0 else {
                return nil
            }

            guard path.pointee.num_data != 0, let data = path.pointee.data else {
                return nil
            }

            let dataCopy = UnsafeMutablePointer<cairo_path_data_t>.allocate(capacity: Int(path.pointee.num_data))
            dataCopy.initialize(from: data, count: Int(path.pointee.num_data))

            let result = UnsafeMutablePointer<cairo_path_t>.allocate(capacity: 1)
            result.pointee.data = dataCopy
            result.pointee.num_data = path.pointee.num_data
            result.pointee.status = path.pointee.status

            return result
        }
    }

    public var destroyFunc: (UnsafeMutablePointer<cairo_path_t>?) -> () {
        return cairo_path_destroy
    }
}

