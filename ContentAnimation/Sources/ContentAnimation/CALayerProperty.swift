//
//  CALayerProperty.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation
import TinyFoundation
import CairoGraphics

@propertyWrapper
public struct CALayerProperty<Type: PublicInitializable> {
    internal let name: String

    public init(name: String) {
        self.name = name
    }

    @available(*, unavailable, message: "Only for CALayer")
    public var wrappedValue: Type {
        get { fatalError("Only for CALayer") }
        set { fatalError("Only for CALayer") }
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

public protocol CALayerValuePropertyType: PublicInitializable {}

public extension CALayerValuePropertyType {
    static func constructValue() -> Value<Self> {
        return Value(self.init())
    }

    func constructValue() -> Value<Self> {
        return Value(self)
    }
}

extension CGRect: CALayerValuePropertyType {}
extension CGSize: CALayerValuePropertyType {}
extension CGPoint: CALayerValuePropertyType {}
extension CGFloat: CALayerValuePropertyType {}
extension CGAffineTransform: CALayerValuePropertyType {}
extension CATransform3D: CALayerValuePropertyType {}
extension CACornerMask: CALayerValuePropertyType {}
