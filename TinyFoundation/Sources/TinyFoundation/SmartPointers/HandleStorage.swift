//
//  SharedPointerStorage.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol HandleStorage<Handle>: Hashable {
    associatedtype Handle

    var handle: Handle { get }
}

public extension HandleStorage where Handle: SmartPointer {
    @_transparent
    var pointer: Handle.Pointer { handle.pointer }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.handle == rhs.handle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(handle)
    }
}

open class SharedPointerStorage<Value>: HandleStorage {
    public typealias Handle = SharedPointer<Value>
    public let handle: Handle

    public init(handle: Handle) {
        self.handle = handle
    }
}

public extension Array where Element: HandleStorage {
    func handles() -> [Element.Handle] {
        return map { $0.handle }
    }

    func optionalHandles() -> [Element.Handle?] {
        return map { $0.handle }
    }
}

public extension Array where Element: HandleStorage, Element.Handle: SmartPointer {
    func pointers() -> [UnsafePointer<Element.Handle.Pointer.Pointee>] {
        return map { UnsafePointer($0.pointer) }
    }

    func optionalPointers() -> [UnsafePointer<Element.Handle.Pointer.Pointee>?] {
        return map { UnsafePointer($0.pointer) }
    }

    func mutablePointers() -> [Element.Handle.Pointer] {
        return map { $0.pointer }
    }

    func optionalMutablePointers() -> [Element.Handle.Pointer?] {
        return map { $0.pointer }
    }

    func smartPointers() -> [Element.Handle] {
        return map { $0.handle }
    }
}
