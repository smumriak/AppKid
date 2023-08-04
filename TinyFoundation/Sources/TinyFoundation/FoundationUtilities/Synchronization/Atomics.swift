//
//  Atomics.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 03.08.2023
//

import Atomics

@propertyWrapper
public struct AtomicSequentiallyConsistent<Value> where Value: AtomicValue, Value.AtomicRepresentation.Value == Value {
    @usableFromInline
    internal var value: ManagedAtomic<Value>

    @_transparent
    public init(wrappedValue value: Value) {
        self.value = ManagedAtomic(value)
    }

    @_transparent
    public var wrappedValue: Value {
        get {
            value.load(ordering: .sequentiallyConsistent)
        }
        set {
            value.store(newValue, ordering: .sequentiallyConsistent)
        }
    }
}

@propertyWrapper
public struct AtomicAcquiring<Value> where Value: AtomicValue, Value.AtomicRepresentation.Value == Value {
    @usableFromInline
    internal var value: ManagedAtomic<Value>

    @_transparent
    public init(wrappedValue value: Value) {
        self.value = ManagedAtomic(value)
    }

    @_transparent
    public var wrappedValue: Value {
        get {
            value.load(ordering: .acquiring)
        }
        set {
            value.store(newValue, ordering: .releasing)
        }
    }
}

@propertyWrapper
public struct AtomicRelaxed<Value> where Value: AtomicValue, Value.AtomicRepresentation.Value == Value {
    @usableFromInline
    internal var value: ManagedAtomic<Value>

    @_transparent
    public init(wrappedValue value: Value) {
        self.value = ManagedAtomic(value)
    }

    @_transparent
    public var wrappedValue: Value {
        get {
            value.load(ordering: .relaxed)
        }
        set {
            value.store(newValue, ordering: .relaxed)
        }
    }
}
