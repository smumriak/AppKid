//
//  EntityFactory.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation

@_marker
public protocol EntityFactory {}

public extension SharedPointerStorage where Handle.Pointee: EntityFactory {
    func create<Info: SimpleEntityInfo>(with info: UnsafePointer<Info>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        var result: UnsafeMutablePointer<Info.Result>? = nil

        try vulkanInvoke {
            Info.createFunction(pointer, info, callbacks, &result)
        }

        return SharedPointer(with: result!) { [unowned self] in
            Info.deleteFunction(self.pointer, $0, callbacks)
        }
    }

    func create<Info: SimpleEntityInfo>(with chain: VulkanStructureChain<Info>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        try chain.withUnsafeChainPointer { info in
            var result: UnsafeMutablePointer<Info.Result>? = nil

            try vulkanInvoke {
                Info.createFunction(pointer, info, callbacks, &result)
            }

            return SharedPointer(with: result!) { [unowned self] in
                Info.deleteFunction(self.pointer, $0, callbacks)
            }
        }
    }
}

public extension SharedPointerStorage where Handle.Pointee: EntityFactory {
    func create<Info: PipelineEntityInfo>(with info: UnsafePointer<Info>, context: UnsafePointer<Info.Context>? = nil, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SharedPointer<Info.Result> where Info.Parent == Handle.Pointee {
        var result: UnsafeMutablePointer<Info.Result>? = nil

        try vulkanInvoke {
            Info.createFunction(pointer, context, 1, info, callbacks, &result)
        }

        return SharedPointer(with: result!) { [unowned self] in
            Info.deleteFunction(self.pointer, $0, callbacks)
        }
    }

    func create<Info: PipelineEntityInfo>(with infos: UnsafeBufferPointer<Info>, context: UnsafePointer<Info.Context>? = nil, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> [SharedPointer<Info.Result>] where Info.Parent == Handle.Pointee {
        var entities: [UnsafeMutablePointer<Info.Result>?] = Array(repeating: nil, count: infos.count)

        try vulkanInvoke {
            Info.createFunction(pointer, context, CUnsignedInt(infos.count), infos.baseAddress, callbacks, &entities)
        }

        return entities.map {
            SharedPointer(with: $0!) { [unowned self] in
                Info.deleteFunction(self.pointer, $0, callbacks)
            }
        }
    }
}
