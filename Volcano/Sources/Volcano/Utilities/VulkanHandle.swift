//
//  VulkanHandle.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import TinyFoundation
import CVulkan

public class VulkanHandle<Handle> where Handle: SmartPointerProtocol {
    public internal(set) var handle: Handle.Pointer_t {
        get { handlePointer.pointer }
        set { handlePointer.pointer = newValue }
    }
    public internal(set) var handlePointer: Handle

    internal init(handlePointer: Handle) {
        self.handlePointer = handlePointer
    }
}
