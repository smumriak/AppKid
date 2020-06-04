//
//  EntityFactory.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

internal protocol EntityFactory {}

internal extension UnsafeMutablePointer where Pointee: EntityFactory {
    typealias CreatorFunction<Parent, Info, Callbacks, Result> = (UnsafeMutablePointer<Parent>?, UnsafePointer<Info>?, UnsafePointer<Callbacks>?, UnsafeMutablePointer<UnsafeMutablePointer<Result>?>?) -> (VkResult)

    func createEntity<Info, Callbacks, Result>(info: UnsafePointer<Info>, callbacks: UnsafePointer<Callbacks>? = nil, using creator: CreatorFunction<Self.Pointee, Info, Callbacks, Result>) throws -> UnsafeMutablePointer<Result> {
        var result: UnsafeMutablePointer<Result>?
        try vulkanInvoke (
            creator(self, info, callbacks, &result)
        )
        return result!
    }

    typealias AllocatorFunction<Parent, Info, Result> = (UnsafeMutablePointer<Parent>?, UnsafePointer<Info>?, UnsafeMutablePointer<UnsafeMutablePointer<Result>?>?) -> (VkResult)

    func allocateMemory<Info, Result>(info: UnsafePointer<Info>, using allocator: AllocatorFunction<Self.Pointee, Info, Result>) throws -> UnsafeMutablePointer<Result> {
        var result: UnsafeMutablePointer<Result>?
        try vulkanInvoke (
            allocator(self, info, &result)
        )
        return result!
    }

}

internal extension VulkanHandle where Handle.Pointee: EntityFactory {
    func createEntity<Info, Callbacks, Result>(info: UnsafePointer<Info>, callbacks: UnsafePointer<Callbacks>? = nil, using creator: Handle.Pointer_t.CreatorFunction<Handle.Pointer_t.Pointee, Info, Callbacks, Result>) throws -> UnsafeMutablePointer<Result> {
        return try handle.createEntity(info: info, using: creator)
    }

    func allocateMemory<Info, Result>(info: UnsafePointer<Info>, using allocator: Handle.Pointer_t.AllocatorFunction<Handle.Pointer_t.Pointee, Info, Result>) throws -> UnsafeMutablePointer<Result> {
        return try handle.allocateMemory(info: info, using: allocator)
    }
}
