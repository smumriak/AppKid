//
//  Synchronized.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 26.09.2021.
//

import Foundation

public extension LockProtocol {
    @_transparent
    func synchronized<T>(_ body: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }

        return try body()
    }

    @_transparent
    func desynchronized<T>(_ body: () throws -> T) rethrows -> T {
        self.unlock()
        defer { self.lock() }

        return try body()
    }
}

@propertyWrapper
public struct Synchronized<Value> {
    @usableFromInline
    internal var value: Value

    @usableFromInline
    internal let lock = RecursiveLock()

    @_transparent
    public init(wrappedValue value: Value) {
        self.value = value
    }

    @_transparent
    public var wrappedValue: Value {
        get {
            lock.synchronized { value }
        }
        set {
            lock.synchronized { value = newValue }
        }
    }

    @_transparent
    public func synchronized<T>(_ body: () throws -> T) rethrows -> T {
        return try lock.synchronized(body)
    }

    @_transparent
    public func desynchronized<T>(_ body: () throws -> T) rethrows -> T {
        return try lock.desynchronized(body)
    }

    @_transparent
    public var projectedValue: Synchronized<Value> {
        self
    }
}
