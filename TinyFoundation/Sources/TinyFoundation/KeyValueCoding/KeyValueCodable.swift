//
//  CopyablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.11.2021.
//

import Foundation

// palkovnik:ExpressibleByStringLiteral maybe?
public protocol KeyValueCodable {
    func value(forKey key: String) -> Any?
    func value(forKeyPath keyPath: String) -> Any?
    func setValue(_ value: Any?, forKey key: String)
    func setValue(_ value: Any?, forKeyPath keyPath: String)
}

public protocol DefaultKeyValueCodable: KeyValueCodable {
    static func defaultValue(forKey key: String) -> Any?
}

// protocol TypedKeyValueCodable: KeyValueCodable {
//     func getValue<Type: PublicInitializable>(forKey key: String) -> Type
//     func getValue<Type: PublicInitializable>(forKeyPath keyPath: String) -> Type
//     func setValue<Type: PublicInitializable>(_ value: Type, forKey key: String)
//     func setValue<Type: PublicInitializable>(_ value: Type, forKeyPath keyPath: String)
// }

// extension CGPoint: KeyValueCodable {
//     public func value(forKey key: String) -> Any? {
//         switch key {
//             case "x": return x
//             case "y": return y
//             default: return nil
//         }
//     }

//     public func value(forKeyPath keyPath: String) -> Any? {
//         return value(forKey: keyPath)
//     }

//     public mutating func setValue(_ value: Any?, forKey key: String) {
//         switch key {
//             case "x": self.x = value as! CGFloat
//             case "y": self.y = value as! CGFloat
//             default: return nil
//         }
//     }

//     public mutating func setValue(_ value: Any?, forKeyPath keyPath: String) {
//         self.setValue(value, forKey: keyPath)
//     }
// }
