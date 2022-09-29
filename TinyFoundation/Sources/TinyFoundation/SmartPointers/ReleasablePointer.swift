//
//  ReleasablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol ReleasableCType {
    static var releaseFunc: (_ pointer: SmartPointer<Self>.Pointer_t?) -> () { get }
}

public extension UnsafeMutablePointer where Pointee: ReleasableCType {
    func release() {
        defer { globalRetainCount.decrement() }
        
        Pointee.releaseFunc(self)
    }
}

public class ReleasablePointer<Pointee>: SmartPointer<Pointee> where Pointee: ReleasableCType {
    public init(with pointer: Pointer_t) {
        super.init(with: pointer, deleter: .custom(Pointee.releaseFunc))
    }

    public override class func allocate(capacity: Int = 1) -> SmartPointer<Pointee> {
        return ReleasablePointer<Pointee>(with: Pointer_t.allocate(capacity: capacity))
    }
}

@propertyWrapper
public struct Releasable<Pointee: ReleasableCType> {
    public typealias StoragePointer = ReleasablePointer<Pointee>

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
