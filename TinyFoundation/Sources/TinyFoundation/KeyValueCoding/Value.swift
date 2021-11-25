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
    public func value<T: StringProtocol & Hashable>(forKey key: T) -> Any? {
        return storedValue.value(forKey: key)
    }

    public func value<T: StringProtocol & Hashable>(forKeyPath keyPath: T) -> Any? {
        return storedValue.value(forKeyPath: keyPath)
    }

    public func setValue<T: StringProtocol & Hashable>(_ value: Any?, forKey key: T) {
        storedValue.setValue(value, forKey: key)
    }

    public func setValue<T: StringProtocol & Hashable>(_ value: Any?, forKeyPath keyPath: T) {
        storedValue.setValue(value, forKeyPath: keyPath)
    }
}
