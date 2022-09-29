//
//  HandleStorage.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol HandleStorageProtocol: Hashable {
    associatedtype Handle

    var handle: Handle { get }
}

public extension HandleStorageProtocol where Handle: SmartPointer {
    @_transparent
    var pointer: Handle.Pointer_t { handle.pointer }
}

public typealias SharedHandleStorage<Pointee> = HandleStorage<SharedPointer<Pointee>>

open class HandleStorage<Handle: SmartPointer>: HandleStorageProtocol {
    public let handle: Handle

    public init(handle: Handle) {
        self.handle = handle
    }

    public static func == (lhs: HandleStorage<Handle>, rhs: HandleStorage<Handle>) -> Bool {
        return lhs.handle == rhs.handle
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(handle)
    }
}

public extension Array where Element: HandleStorageProtocol {
    func handles() -> [Element.Handle] {
        return map { $0.handle }
    }

    func optionalHandles() -> [Element.Handle?] {
        return map { $0.handle }
    }
}

public extension Array where Element: HandleStorageProtocol, Element.Handle: SmartPointer {
    func pointers() -> [UnsafePointer<Element.Handle.Pointer_t.Pointee>] {
        return map { UnsafePointer($0.pointer) }
    }

    func optionalPointers() -> [UnsafePointer<Element.Handle.Pointer_t.Pointee>?] {
        return map { UnsafePointer($0.pointer) }
    }

    func mutablePointers() -> [Element.Handle.Pointer_t] {
        return map { $0.pointer }
    }

    func optionalMutablePointers() -> [Element.Handle.Pointer_t?] {
        return map { $0.pointer }
    }

    func smartPointers() -> [Element.Handle] {
        return map { $0.handle }
    }
}
