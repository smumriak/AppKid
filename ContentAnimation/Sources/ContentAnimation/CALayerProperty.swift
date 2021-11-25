//
//  CALayerProperty.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation
import TinyFoundation

@propertyWrapper
public final class CALayerProperty<Type: PublicInitializable> {
    internal let name: String

    public init(name: String) {
        self.name = name
    }

    @available(*, unavailable, message: "Only for CALayer")
    public var wrappedValue: Type {
        get { fatalError("Only for CALayer") }
        set { fatalError("Only for CALayer") }
    }

    public static subscript<InstanceType: AnyObject & DefaultKeyValueCodable>(
        _enclosingInstance instance: InstanceType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<InstanceType, Type>,
        storage storageKeyPath: ReferenceWritableKeyPath<InstanceType, CALayerProperty>
    ) -> Type {
        get {
            let key = instance[keyPath: storageKeyPath].name

            if let result = instance.value(forKey: key) {
                return result as! Type
            } else if let result = InstanceType.defaultValue(forKey: key) {
                return result as! Type
            } else {
                return Type()
            }
        }
        set {
            let key = instance[keyPath: storageKeyPath].name

            instance.setValue(newValue, forKey: key)
        }
    }
}
