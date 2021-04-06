//
//  CGFloat+Convenience.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 04.04.2020.
//

import Foundation

public extension CGFloat {
    init?(_ string: String) {
        if let result = Double(string)?.cgFloat {
            self = result
        } else {
            return nil
        }
    }
}   

public extension BinaryFloatingPoint {
    var cgFloat: CGFloat { CGFloat(self) }
}