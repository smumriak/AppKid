//
//  CAProperty.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation
import TinyFoundation
import CairoGraphics

internal protocol CAPropertyProtocol {
    var name: String { get }
    func createInstance() -> Any
}

@propertyWrapper
public struct CAProperty<Type: PublicInitializable> {
    internal let name: String

    public init(name: String) {
        self.name = name
    }

    @available(*, unavailable, message: "Only for DefaultKeyValueCodable classes")
    public var wrappedValue: Type {
        get { fatalError("Only for DefaultKeyValueCodable classes") }
        set { fatalError("Only for DefaultKeyValueCodable classes") }
    }

    public static subscript<InstanceType: DefaultKeyValueCodable>(
        _enclosingInstance instance: InstanceType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<InstanceType, Type>,
        storage storageKeyPath: ReferenceWritableKeyPath<InstanceType, Self>
    ) -> Type {
        get {
            let key = instance[keyPath: storageKeyPath].name

            if let result = instance.value(forKey: key) ?? InstanceType.defaultValue(forKey: key) {
                if let valueResult = result as? Value<Type> {
                    return valueResult.storedValue
                } else {
                    return result as! Type
                }
            } else {
                return Type()
            }
        }
        set {
            let key = instance[keyPath: storageKeyPath].name

            // this does not make any copies since this property wrapper can be used on classes only. this is just a way to make compiler shut up about using mutating functions
            var instanceMutable = instance

            instanceMutable.setValue(newValue, forKey: key)
        }
    }
}

extension CAProperty: CAPropertyProtocol {
    func createInstance() -> Any {
        return Type()
    }
}
