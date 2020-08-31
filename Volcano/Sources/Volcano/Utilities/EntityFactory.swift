//
//  EntityFactory.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation
import CVulkan

public protocol EntityFactory {}

public extension UnsafeMutablePointer where Pointee: EntityFactory {
    typealias AllocatorFunction<Parent, Info, Result> = (UnsafeMutablePointer<Parent>?, UnsafePointer<Info>?, UnsafeMutablePointer<UnsafeMutablePointer<Result>?>?) -> (VkResult)

    func allocateMemory<Info, Result>(info: UnsafePointer<Info>, using allocator: AllocatorFunction<Self.Pointee, Info, Result>) throws -> UnsafeMutablePointer<Result> {
        var result: UnsafeMutablePointer<Result>?
        try vulkanInvoke {
            allocator(self, info, &result)
        }
        return result!
    }
}

public extension VulkanHandle where Handle.Pointee: EntityFactory {
    func allocateMemory<Info, Result>(info: UnsafePointer<Info>, using allocator: Handle.Pointer_t.AllocatorFunction<Handle.Pointer_t.Pointee, Info, Result>) throws -> UnsafeMutablePointer<Result> {
        return try handle.allocateMemory(info: info, using: allocator)
    }

    func create<Info: EntityInfo>(with info: UnsafePointer<Info>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SmartPointer<Info.Result> where Info.Parent == Handle.Pointee {
        var pointer: UnsafeMutablePointer<Info.Result>?

        try vulkanInvoke {
            Info.createFunction(handle, info, callbacks, &pointer)
        }

        return SmartPointer(with: pointer!) { [unowned self] in
            Info.deleteFunction(handle, $0, callbacks)
        }
    }
}
