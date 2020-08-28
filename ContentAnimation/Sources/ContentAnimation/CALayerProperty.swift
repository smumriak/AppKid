//
//  CALayerProperty.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation

internal protocol CALayerPropertyProtocol: class {
    var name: String { get }
}

@propertyWrapper
public final class CALayerProperty<Type>: CALayerPropertyProtocol {
    private var _value: Type
    private let _name: String

    public init(wrappedValue: Type, name: String) {
        _name = name
        _value = wrappedValue
    }

    public var wrappedValue: Type {
        get { return _value }
        set { _value = newValue }
    }

    public var name: String { return _name }
}
