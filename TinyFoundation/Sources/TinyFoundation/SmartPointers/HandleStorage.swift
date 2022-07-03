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

public protocol SmartPointerHandleStorageProtocol: HandleStorageProtocol {
    associatedtype SmartPointerHandle_t: SmartPointerProtocol
    var handlePointer: SmartPointerHandle_t { get }
}

open class HandleStorage<Handle>: HandleStorageProtocol, SmartPointerHandleStorageProtocol where Handle: SmartPointerProtocol {
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

public extension Array where Element: SmartPointerHandleStorageProtocol, Element.Handle_t == Element.SmartPointerHandle_t.Pointer_t {
    func pointers() -> [UnsafePointer<Element.SmartPointerHandle_t.Pointer_t.Pointee>] {
        return map { UnsafePointer($0.handle) }
    }

    func optionalPointers() -> [UnsafePointer<Element.SmartPointerHandle_t.Pointer_t.Pointee>?] {
        return map { UnsafePointer($0.handle) }
    }

    func mutablePointers() -> [Element.SmartPointerHandle_t.Pointer_t] {
        return map { $0.handle }
    }

    func optionalMutablePointers() -> [Element.SmartPointerHandle_t.Pointer_t?] {
        return map { $0.handle }
    }

    func smartPointers() -> [Element.SmartPointerHandle_t] {
        return map { $0.handlePointer }
    }
}
