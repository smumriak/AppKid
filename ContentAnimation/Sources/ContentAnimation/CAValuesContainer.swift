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

open class CAValuesContainer: NSObject, DefaultKeyValueCodable {
    @_spi(AppKid) open var values: [String: Any] = [:]

    public override required init() {
        super.init()
    }

    open class func defaultValue<T: StringProtocol & Hashable>(forKey key: T) -> Any? {
        return nil
    }
    
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
            let key = keys[0]
            let tailKeyPath = keys[1]
            if var object = self.value(forKey: key) as? KeyValueCodable {
                object.setValue(value, forKeyPath: tailKeyPath)
            } else if var object = Self.defaultValue(forKey: key) as? KeyValueCodable {
                object.setValue(value, forKeyPath: tailKeyPath)
                setValue(object, forKey: key)
            } else {
                // supporting this case requires some tricky logic to determine the type of object for this particular key. either some reflection or mainatining default values for all known properties
                fatalError("Empty values are not yet supported.")
            }
        } else {
            setValue(value, forKey: keys[0])
        }
    }
}
