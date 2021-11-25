//
//  CAValuesContainer.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 25.11.2020.
//

import Foundation
import CoreFoundation
import CairoGraphics
import TinyFoundation

@_spi(AppKid) open class CAValuesContainer: NSObject, KeyValueCodable {
    open var values: [String: Any] = [:]
    
    open func value<T: StringProtocol & Hashable>(forKey key: T) -> Any? {
        if key.isEmpty {
            return nil
        }

        return values[String(key)]
    }

    open func value<T: StringProtocol & Hashable>(forKeyPath keyPath: T) -> Any? {
        if keyPath.isEmpty {
            return nil
        }

        let keys = keyPath.split(separator: ".", maxSplits: 1)

        if keys.count == 2 {
            if let object = self.value(forKey: keys[0]) as? KeyValueCodable {
                return object.value(forKeyPath: keys[1])
            } else {
                return nil
            }
        } else {
            return value(forKey: keys[0])
        }
    }

    open func setValue<T: StringProtocol & Hashable>(_ value: Any?, forKey key: T) {
        if key.isEmpty {
            return
        }

        values[String(key)] = value
    }

    open func setValue<T: StringProtocol & Hashable>(_ value: Any?, forKeyPath keyPath: T) {
        if keyPath.isEmpty {
            return
        }

        let keys = keyPath.split(separator: ".", maxSplits: 1)

        if keys.count == 2 {
            if var object = self.value(forKey: String(keys[0])) as? KeyValueCodable {
                object.setValue(value, forKeyPath: keys[1])
            }
        } else {
            setValue(value, forKey: keys[0])
        }
    }
}
