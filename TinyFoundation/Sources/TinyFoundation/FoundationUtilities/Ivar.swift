//
//  Ivar.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 16.07.2022
//

import Foundation

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
