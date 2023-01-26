//
//  ReleasablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol ReleasableCType {
    static var releaseFunc: (_ pointer: SharedPointer<Self>.Pointer?) -> () { get }
}

public extension UnsafeMutablePointer where Pointee: ReleasableCType {
    func release() {
        defer { globalRetainCount.wrappingDecrement(by: 1, ordering: .relaxed) }
        
        Pointee.releaseFunc(self)
    }
}

public typealias ReleasablePointer<Pointee> = SharedPointer<Pointee>

public extension SharedPointer where Pointee: ReleasableCType {
    convenience init(with pointer: Pointer) {
        self.init(with: pointer, deleter: .custom(Pointee.releaseFunc))
    }
}

@propertyWrapper
public struct Releasable<Pointee: ReleasableCType> {
    public typealias StoragePointer = ReleasablePointer<Pointee>

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
