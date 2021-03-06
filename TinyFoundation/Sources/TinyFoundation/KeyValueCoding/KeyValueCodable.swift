//
//  KeyValueCodable.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.11.2021.
//

import Foundation

// smumriak:ExpressibleByStringLiteral maybe?
public protocol KeyValueCodable {
    func value(forKey key: String) -> Any?
    func value(forKeyPath keyPath: String) -> Any?

    mutating func setValue(_ value: Any?, forKey key: String)
    mutating func setValue(_ value: Any?, forKeyPath keyPath: String)

    func willChangeValue(forKey key: String)
    func didChangeValue(forKey key: String)

    // Needed?
    // func value(forUndefinedKey key: T) -> Any?
    // mutating func setValue(_ value: Any?, forUndefinedKey key: T)
}

public extension KeyValueCodable {
    func willChangeValue(forKey key: String) {}
    func didChangeValue(forKey key: String) {}
}

public protocol DefaultKeyValueCodable: KeyValueCodable {
    static func defaultValue(forKey key: String) -> Any?
}

extension CGRect: KeyValueCodable {
    public func value(forKey key: String) -> Any? {
        switch key {
            case "origin": return origin
            case "size": return size

            case "x": return origin.x
            case "origin.x": return origin.x

            case "y": return origin.y
            case "origin.y": return origin.y

            case "width": return size.width
            case "size.width": return size.width

            case "height": return size.height
            case "size.height": return size.height
            
            default: return nil
        }
    }

    public func value(forKeyPath keyPath: String) -> Any? {
        return value(forKey: keyPath)
    }

    public mutating func setValue(_ value: Any?, forKey key: String) {
        switch key {
            case "origin": return origin = value as! CGPoint
            case "size": return size = value as! CGSize

            case "x": origin.x = CGFloat(any: value)!
            case "origin.x": origin.x = CGFloat(any: value)!

            case "y": origin.y = CGFloat(any: value)!
            case "origin.y": origin.y = CGFloat(any: value)!

            case "width": size.width = CGFloat(any: value)!
            case "size.width": size.width = CGFloat(any: value)!

            case "height": size.height = CGFloat(any: value)!
            case "size.height": size.height = CGFloat(any: value)!

            default: break
        }
    }

    public mutating func setValue(_ value: Any?, forKeyPath keyPath: String) {
        self.setValue(value, forKey: keyPath)
    }
}

public extension CGFloat {
    init?(any: Any?) {
        switch any {
            case let .some(result as CGFloat): self.init(result)
            case let .some(result as Float): self.init(result)
            case let .some(result as Double): self.init(result)
            case let .some(result as Int): self.init(result)
            case let .some(result as Int8): self.init(result)
            case let .some(result as Int16): self.init(result)
            case let .some(result as Int32): self.init(result)
            case let .some(result as Int64): self.init(result)
            case let .some(result as UInt): self.init(result)
            case let .some(result as UInt8): self.init(result)
            case let .some(result as UInt16): self.init(result)
            case let .some(result as UInt32): self.init(result)
            case let .some(result as UInt64): self.init(result)
            default: return nil
        }
    }
}

extension CGSize: KeyValueCodable {
    public func value(forKey key: String) -> Any? {
        switch key {
            case "width": return width
            case "height": return height
            default: return nil
        }
    }

    public func value(forKeyPath keyPath: String) -> Any? {
        return value(forKey: keyPath)
    }

    public mutating func setValue(_ value: Any?, forKey key: String) {
        switch key {
            case "width": return width = CGFloat(any: value)!
            case "height": return height = CGFloat(any: value)!
            default: break
        }
    }

    public mutating func setValue(_ value: Any?, forKeyPath keyPath: String) {
        self.setValue(value, forKey: keyPath)
    }
}

extension CGPoint: KeyValueCodable {
    public func value(forKey key: String) -> Any? {
        switch key {
            case "x": return x
            case "y": return y
            default: return nil
        }
    }

    public func value(forKeyPath keyPath: String) -> Any? {
        return value(forKey: keyPath)
    }

    public mutating func setValue(_ value: Any?, forKey key: String) {
        switch key {
            case "x": x = CGFloat(any: value)!
            case "y": y = CGFloat(any: value)!
            default: break
        }
    }

    public mutating func setValue(_ value: Any?, forKeyPath keyPath: String) {
        self.setValue(value, forKey: keyPath)
    }
}
