//
//  HandleStorage.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol HandleStorageProtocol {
    associatedtype Handle_t

    var handle: Handle_t { get }
}

open class HandleStorage<Handle>: NSObject, HandleStorageProtocol where Handle: SmartPointerProtocol {
    public var handle: Handle.Pointer_t {
        handlePointer.pointer
    }

    public let handlePointer: Handle

    public init(handlePointer: Handle) {
        self.handlePointer = handlePointer

        super.init()
    }
}

public extension Array where Element: HandleStorageProtocol {
    func pointers() -> [Element.Handle_t] {
        return map { $0.handle }
    }

    func optionalPointers() -> [Element.Handle_t?] {
        return map { $0.handle }
    }
}
