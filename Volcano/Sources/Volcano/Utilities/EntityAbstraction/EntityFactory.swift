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
    func create<Info: SimpleEntityInfo>(with info: UnsafePointer<Info>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        var pointer: UnsafeMutablePointer<Info.Result>? = nil

        try vulkanInvoke {
            Info.createFunction(handle, info, callbacks, &pointer)
        }

        return SharedPointer(with: pointer!) { [unowned self] in
            Info.deleteFunction(self.handle, $0, callbacks)
        }
    }

    func create<Info: SimpleEntityInfo>(with chain: VulkanStructureChain<Info>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try chain.withUnsafeChainPointer { info in
            var pointer: UnsafeMutablePointer<Info.Result>? = nil

            try vulkanInvoke {
                Info.createFunction(handle, info, callbacks, &pointer)
            }

            return SharedPointer(with: pointer!) { [unowned self] in
                Info.deleteFunction(self.handle, $0, callbacks)
            }
        }
    }
}

public extension HandleStorage where Handle.Pointee: EntityFactory {
    func create<Info: PipelineEntityInfo>(with info: UnsafePointer<Info>, cache: VkPipelineCache? = nil, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        var pointer: UnsafeMutablePointer<Info.Result>? = nil

        try vulkanInvoke {
            Info.createFunction(handle, cache, 1, info, callbacks, &pointer)
        }

        return SharedPointer(with: pointer!) { [unowned self] in
            Info.deleteFunction(self.handle, $0, callbacks)
        }
    }

    func create<Info: PipelineEntityInfo>(with infos: UnsafeBufferPointer<Info>, cache: VkPipelineCache? = nil, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> [SharedPointer<Info.Result>] where Info.Parent == Handle.Pointee {
        var entities: [UnsafeMutablePointer<Info.Result>?] = Array(repeating: nil, count: infos.count)

        try vulkanInvoke {
            Info.createFunction(handle, cache, CUnsignedInt(infos.count), infos.baseAddress, callbacks, &entities)
        }

        return entities.map {
            SharedPointer(with: $0!) { [unowned self] in
                Info.deleteFunction(self.handle, $0, callbacks)
            }
        }
    }
}
