//
//  CAAnimation.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 25.11.2020.
//

import Foundation
import CoreFoundation
import CairoGraphics
import TinyFoundation

open class CAAnimation: CAValuesContainer, CAMediaTiming {
    @_spi(AppKid) open var valuesContainer = CAValuesContainer()
    
    // MARK: Key Value Coding

    open override class func defaultValue<T: StringProtocol & Hashable>(forKey key: T) -> Any? {
        switch key {
            default: return super.defaultValue(forKey: key)
        }
    }
}
