//
//  EntityFactory.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation
import CVulkan

@_marker
public protocol EntityFactory {}

public extension HandleStorage where Handle.Pointee: EntityFactory {
    func create<Info: EntityInfo>(with info: UnsafePointer<Info>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SmartPointer<Info.Result> where Info.Parent == Handle.Pointee {
        var pointer: UnsafeMutablePointer<Info.Result>? = nil

        try vulkanInvoke {
            Info.createFunction(handle, info, callbacks, &pointer)
        }

        return SmartPointer(with: pointer!) { [unowned self] in
            Info.deleteFunction(self.handle, $0, callbacks)
        }
    }

    func create<Info: EntityInfo>(with chain: VulkanStructureChain<Info>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SmartPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try chain.withUnsafeChainPointer { info in
            var pointer: UnsafeMutablePointer<Info.Result>? = nil

            try vulkanInvoke {
                Info.createFunction(handle, info, callbacks, &pointer)
            }

            return SmartPointer(with: pointer!) { [unowned self] in
                Info.deleteFunction(self.handle, $0, callbacks)
            }
        }
    }
}
