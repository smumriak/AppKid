//
//  Synchronization.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 26.09.2021.
//

import Foundation

public extension LockProtocol {
    func synchronized<T>(_ body: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }

        return try body()
    }

    func desynchronized<T>(_ body: () throws -> T) rethrows -> T {
        self.unlock()
        defer { self.lock() }

        return try body()
    }
}

@propertyWrapper
public struct Synchronized<Value> {
    private var value: Value
    private let lock = RecursiveLock()

    public init(wrappedValue value: Value) {
        self.value = value
    }

    public var wrappedValue: Value {
        get {
            lock.synchronized { value }
        }
        set {
            lock.synchronized { value = newValue }
        }
    }

    public func synchronized<T>(_ body: () throws -> T) rethrows -> T {
        return try lock.synchronized(body)
    }

    public var projectedValue: Synchronized<Value> {
        self
    }
}
