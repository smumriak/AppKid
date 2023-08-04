//
//  Ivar.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 16.07.2022
//

import Foundation

/// Defines a non-null property that is backed by optional
/// Use this in places where you "guarantee" this property will be initialized before first use. Generally unsafe.
@propertyWrapper
public struct IvarBacked<Value> {
    private var value: Value!

    public init() {}

    public init(wrappedValue value: Value) {
        self.value = value
    }

    public var wrappedValue: Value {
        get {
            value
        }
        set {
            value = newValue
        }
    }
}
