//
//  RetainablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

public protocol RetainableCType: ReleasableCType {
    static var retainFunc: (_ pointer: SharedPointer<Self>.Pointer?) -> (SharedPointer<Self>.Pointer?) { get }
}

public extension UnsafeMutablePointer where Pointee: RetainableCType {
    @discardableResult
    func retain() -> UnsafeMutablePointer<Pointee> {
        defer { globalRetainCount.increment() }

        return Pointee.retainFunc(self)!
    }
}

public typealias RetainablePointer<Pointee> = SharedPointer<Pointee>

public extension SharedPointer where Pointee: RetainableCType {
    convenience init(retaining pointer: Pointer) {
        self.init(with: pointer.retain())
    }

    convenience init(withRetained pointer: Pointer) {
        defer { globalRetainCount.increment() }
        
        self.init(with: pointer)
    }

    convenience init(other: SharedPointer<Pointee>) {
        self.init(with: other.pointer)
    }
}

@propertyWrapper
public struct Retainable<Pointee: RetainableCType> {
    public typealias StoragePointer = RetainablePointer<Pointee>

    public var pointer: StoragePointer

    public var wrappedValue: StoragePointer.Pointer {
        get {
            pointer.pointer
        }
        set {
            pointer = StoragePointer(with: newValue)
        }
    }

    public init(wrappedValue: StoragePointer.Pointer) {
        self.pointer = StoragePointer(withRetained: wrappedValue)
    }

    public init(wrappedValue: StoragePointer) {
        self.pointer = wrappedValue
    }
}
