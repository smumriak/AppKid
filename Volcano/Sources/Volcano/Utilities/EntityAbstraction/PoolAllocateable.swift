//
//  PoolAllocateable.swift
//  Volcano
//
//  Created by Serhii Mumriak on 05.10.2022
//

import CVulkan

public protocol EntityPool: VkDeviceEntity {
    associatedtype Allocateable: PoolAllocateable where Allocateable.Pool == Self
}

public protocol PoolAllocateable: VkDeviceEntity {
    associatedtype Pool: EntityPool where Pool.Allocateable == Self
    associatedtype Info: PoolAllocateInfo where Info.Result == Self
}

public protocol PoolAllocateInfo: DeviceEntityInfo where Result: PoolAllocateable, CreateFunction == AllocateFunction, DeleteFunction == FreeFunction {
    typealias AllocateFunction = (_ parent: ParentPointer?,
                                  _ pAllocateInfo: PointerToSelf?,
                                  _ pResult: UnsafeMutablePointer<ResultPointer?>?) -> (VkResult)

    typealias FreeFunction = (_ parent: ParentPointer?,
                              _ info: UnsafeMutablePointer<Result.Pool>?,
                              _ count: CUnsignedInt,
                              _ buffers: UnsafePointer<ResultPointer?>?) -> (VkResult)
}

extension VkCommandBufferAllocateInfo: PoolAllocateInfo {
    public typealias Result = VkCommandBuffer_T
    public static var allocateFunction = vkAllocateCommandBuffers
    public static var freeFunction = vkFreeCommandBuffers
}

extension VkCommandPool_T: EntityPool {
    public typealias Allocateable = VkCommandBuffer_T
}

extension VkCommandBuffer_T: PoolAllocateable {
    public typealias Pool = VkCommandPool_T
    public typealias Info = VkCommandBufferAllocateInfo
}

extension VkDescriptorSetAllocateInfo: PoolAllocateInfo {
    public typealias Result = VkDescriptorSet_T
    public static var allocateFunction = vkAllocateDescriptorSets
    public static var freeFunction = vkFreeDescriptorSets
}

extension VkDescriptorPool_T: EntityPool {
    public typealias Allocateable = VkDescriptorSet_T
}

extension VkDescriptorSet_T: PoolAllocateable {
    public typealias Pool = VkDescriptorPool_T
    public typealias Info = VkDescriptorSetAllocateInfo
}
