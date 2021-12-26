//
//  Value.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.11.2021.
//

import Foundation

public class Value<Type: PublicInitializable>: PublicInitializable {
    public var storedValue: Type

    public init(_ storedValue: Type) {
        self.storedValue = storedValue
    }

    public convenience required init() {
        self.init(Type())
    }
}

extension Value: KeyValueCodable where Type: KeyValueCodable {
    public func value(forKey key: String) -> Any? {
        return storedValue.value(forKey: key)
    }

    public func value(forKeyPath keyPath: String) -> Any? {
        return storedValue.value(forKeyPath: keyPath)
    }

    public func setValue(_ value: Any?, forKey key: String) {
        storedValue.setValue(value, forKey: key)
    }

    public func setValue(_ value: Any?, forKeyPath keyPath: String) {
        storedValue.setValue(value, forKeyPath: keyPath)
    }
}
