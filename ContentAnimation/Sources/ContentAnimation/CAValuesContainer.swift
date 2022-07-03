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

open class CAValuesContainer: DefaultKeyValueCodable {
    @_spi(AppKid) open var values: [AnyHashable: Any] = [:]

    open class func defaultValue(forKey key: String) -> Any? {
        return nil
    }

    open func value(forKey key: String) -> Any? {
        if key.isEmpty {
            return nil
        }

        return values[key]
    }

    open func value(forKeyPath keyPath: String) -> Any? {
        if keyPath.isEmpty {
            return nil
        }

        let keys = keyPath.split(separator: ".", maxSplits: 1)
        let key = String(keys[0])

        if keys.count == 2 {
            let tailKeyPath = String(keys[1])
            if let object = self.value(forKey: key) as? KeyValueCodable {
                return object.value(forKeyPath: tailKeyPath)
            } else {
                return nil
            }
        } else {
            return value(forKey: key)
        }
    }

    open func setValue(_ value: Any?, forKey key: String) {
        if key.isEmpty {
            return
        }

        willChangeValue(forKey: key)
        
        values[key] = value

        didChangeValue(forKey: key)
    }

    open func setValue(_ value: Any?, forKeyPath keyPath: String) {
        if keyPath.isEmpty {
            return
        }

        let keys = keyPath.split(separator: ".", maxSplits: 1)
        let key = String(keys[0])

        if keys.count == 2 {
            let tailKeyPath = String(keys[1])
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
            setValue(value, forKey: key)
        }
    }

    open func willChangeValue(forKey key: String) {}

    open func didChangeValue(forKey key: String) {}
}

extension CAValuesContainer: Equatable {
    public static func == (lhs: CAValuesContainer, rhs: CAValuesContainer) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
