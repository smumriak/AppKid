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

open class CAAnimation: NSObject, CAMediaTiming, DefaultKeyValueCodable {
    @_spi(AppKid) open var valuesContainer = CAValuesContainer()
    
    // MARK: Key Value Coding

    open class func defaultValue<T: StringProtocol & Hashable>(forKey key: T) -> Any? {
        switch key {
            default: return nil
        }
    }

    open func value<T: StringProtocol & Hashable>(forKey key: T) -> Any? {
        valuesContainer.value(forKey: key)
    }

    open func value<T: StringProtocol & Hashable>(forKeyPath keyPath: T) -> Any? {
        valuesContainer.value(forKeyPath: keyPath)
    }

    open func setValue<T: StringProtocol & Hashable>(_ value: Any?, forKey key: T) {
        valuesContainer.setValue(value, forKey: key)
    }

    open func setValue<T: StringProtocol & Hashable>(_ value: Any?, forKeyPath keyPath: T) {
        valuesContainer.setValue(value, forKeyPath: keyPath)
    }
}
