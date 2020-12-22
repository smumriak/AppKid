//
//  HandleStorage.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

open class HandleStorage<Handle>: NSObject where Handle: SmartPointerProtocol { 
    open internal(set) var handle: Handle.Pointer_t {
        get { handlePointer.pointer }
        set { handlePointer.pointer = newValue }
    }

    open internal(set) var handlePointer: Handle

    public init(handlePointer: Handle) {
        self.handlePointer = handlePointer

        super.init()
    }
}
