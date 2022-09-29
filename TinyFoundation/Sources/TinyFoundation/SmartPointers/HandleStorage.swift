//
//  HandleStorage.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol HandleStorageProtocol: Hashable {
    associatedtype Handle_t

    var handle: Handle_t { get }
}

public protocol SharedPointerHandleStorageProtocol: HandleStorageProtocol {
    associatedtype SharedPointerHandle_t: SmartPointer
    var handlePointer: SharedPointerHandle_t { get }
}

public typealias SharedHandleStorage<Pointee> = HandleStorage<SharedPointer<Pointee>>

open class HandleStorage<Handle: SmartPointer>: SharedPointerHandleStorageProtocol {
    public var handle: Handle.Pointer_t {
        handlePointer.pointer
    }

    public let handlePointer: Handle

    public init(handlePointer: Handle) {
        self.handlePointer = handlePointer
    }

    public static func == (lhs: HandleStorage<Handle>, rhs: HandleStorage<Handle>) -> Bool {
        return lhs.handlePointer == rhs.handlePointer
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(handlePointer)
    }
}

public extension Array where Element: HandleStorageProtocol {
    func handles() -> [Element.Handle_t] {
        return map { $0.handle }
    }

    func optionalHandles() -> [Element.Handle_t?] {
        return map { $0.handle }
    }
}

public extension Array where Element: SharedPointerHandleStorageProtocol, Element.Handle_t == Element.SharedPointerHandle_t.Pointer_t {
    func pointers() -> [UnsafePointer<Element.SharedPointerHandle_t.Pointer_t.Pointee>] {
        return map { UnsafePointer($0.handle) }
    }

    func optionalPointers() -> [UnsafePointer<Element.SharedPointerHandle_t.Pointer_t.Pointee>?] {
        return map { UnsafePointer($0.handle) }
    }

    func mutablePointers() -> [Element.SharedPointerHandle_t.Pointer_t] {
        return map { $0.handle }
    }

    func optionalMutablePointers() -> [Element.SharedPointerHandle_t.Pointer_t?] {
        return map { $0.handle }
    }

    func smartPointers() -> [Element.SharedPointerHandle_t] {
        return map { $0.handlePointer }
    }
}
