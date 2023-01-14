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

public typealias CopyablePointer<Pointee> = SharedPointer<Pointee>

public extension SharedPointer where Pointee: CopyableCType {
    convenience init(copying other: CopyablePointer<Pointee>) {
        self.init(with: other.pointer.copy())
    }
}

@propertyWrapper
public struct Copyable<Pointee: CopyableCType> {
    public typealias StoragePointer = CopyablePointer<Pointee>

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
        self.pointer = StoragePointer(with: wrappedValue)
    }

    public init(wrappedValue: StoragePointer) {
        self.pointer = wrappedValue
    }
}
