//
//  RetainablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

public protocol RetainableCType: ReleasableCType {
    static var retainFunc: (_ pointer: SharedPointer<Self>.Pointer_t?) -> (SharedPointer<Self>.Pointer_t?) { get }
}

public extension UnsafeMutablePointer where Pointee: RetainableCType {
    @discardableResult
    func retain() -> UnsafeMutablePointer<Pointee> {
        defer { globalRetainCount.increment() }

        return Pointee.retainFunc(self)!
    }
}

public class RetainablePointer<Pointee>: ReleasablePointer<Pointee> where Pointee: RetainableCType {
    public override init(with pointer: Pointer_t) {
        super.init(with: pointer.retain())
    }

    public init(withRetained pointer: Pointer_t) {
        defer { globalRetainCount.increment() }
        
        super.init(with: pointer)
    }

    public convenience init(other: RetainablePointer<Pointee>) {
        self.init(with: other.pointer)
    }
}

@propertyWrapper
public struct Retainable<Pointee: RetainableCType> {
    public typealias StoragePointer = RetainablePointer<Pointee>

    public var pointer: StoragePointer

    public var wrappedValue: StoragePointer.Pointer_t {
        get {
            pointer.pointer
        }
        set {
            pointer = StoragePointer(with: newValue)
        }
    }

    public init(wrappedValue: StoragePointer.Pointer_t) {
        self.pointer = StoragePointer(withRetained: wrappedValue)
    }

    public init(wrappedValue: StoragePointer) {
        self.pointer = wrappedValue
    }
}
