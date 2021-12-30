//
//  CopyablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.02.2020.
//

import Foundation

public protocol CopyableCType: ReleasableCType {
    static var copyFunc: (_ pointer: UnsafePointer<Self>?) -> (UnsafeMutablePointer<Self>?) { get }
}

public extension UnsafeMutablePointer where Pointee: CopyableCType {
    func copy() -> UnsafeMutablePointer<Pointee> {
        defer { globalRetainCount.increment() }
        
        return Pointee.copyFunc(self)!
    }
}

public final class CopyablePointer<Pointee>: ReleasablePointer<Pointee> where Pointee: CopyableCType {
    public override init(with pointer: Pointer_t) {
        defer { globalRetainCount.increment() }

        super.init(with: pointer)
    }

    public init(copy other: CopyablePointer<Pointee>) {
        super.init(with: other.pointer.copy())
    }
}

@propertyWrapper
public struct Copyable<Pointee: CopyableCType> {
    public typealias StoragePointer = CopyablePointer<Pointee>

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
        self.pointer = StoragePointer(with: wrappedValue)
    }

    public init(wrappedValue: StoragePointer) {
        self.pointer = wrappedValue
    }
}
