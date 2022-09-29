//
//  VulkanMemoryAllocator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import TinyFoundation
import VulkanMemoryAllocatorAdapted

public class VulkanMemoryAllocator: SharedHandleStorage<VmaAllocator_T>, MemoryAllocator {
    public typealias Allocation = SharedHandleStorage<VmaAllocation_T>

    public internal(set) unowned var device: Device

    public required init(device: Device) throws {
        self.device = device

        let flags: VmaAllocatorCreateFlagBits = []

        var info = VmaAllocatorCreateInfo(
            flags: flags.rawValue,
            physicalDevice: device.physicalDevice.handle,
            device: device.handle,
            preferredLargeHeapBlockSize: 0,
            pAllocationCallbacks: nil,
            pDeviceMemoryCallbacks: nil,
            pHeapSizeLimit: nil,
            pVulkanFunctions: nil,
            instance: device.instance.handle,
            vulkanApiVersion: (1 << 22) | (0 << 12) | 0,
            pTypeExternalMemoryHandleTypes: nil)

        var handle: VmaAllocator? = nil
        try vulkanInvoke {
            vmaCreateAllocator(&info, &handle)
        }

        let handlePointer = SharedPointer(with: handle!, deleter: .custom {
            vmaDestroyAllocator($0)
        })

        super.init(handlePointer: handlePointer)
    }

    public func create<Descriptor: MemoryAllocateDescriptor>(with descriptor: Descriptor) throws -> (result: Descriptor.Result, memoryChunk: MemoryChunk) {
        var entityHandle: UnsafeMutablePointer<Descriptor.Info.Result>? = nil
        var allocationHandle: VmaAllocation? = nil
        var allocationInfo: VmaAllocationInfo = VmaAllocationInfo()

        try descriptor.withUnsafeAllocationCreateInfoPointer { allocationCreateInfo in
            try descriptor.withUnsafeEntityCreateInfoPointer { entityCreateInfo in
                try vulkanInvoke {
                    Descriptor.Info.vmaCreateFunction(handle, entityCreateInfo, allocationCreateInfo, &entityHandle, &allocationHandle, &allocationInfo)
                }
            }
        }

        let entityHandlePointer = SharedPointer(with: entityHandle!) { [unowned device] in
            Descriptor.Info.deleteFunction(device.handle, $0, nil)
        }

        let allocationHandlePointer = SharedPointer(with: allocationHandle!) { [unowned self] in
            vmaFreeMemory(self.handle, $0)
        }

        let allocation = Allocation(handlePointer: allocationHandlePointer)
        
        let memoryChunk = try VMAMemoryChunk(allocator: self, allocation: allocation, info: allocationInfo, memoryProperties: descriptor.requiredMemoryProperties)

        let result = try descriptor.createEntity(device: device, handlePointer: entityHandlePointer, memoryChunk: memoryChunk)

        return (result, memoryChunk)
    }

    public func allocate<Descriptor: MemoryAllocateDescriptor>(for memoryBacked: Descriptor.Result.SharedPointerHandle, descriptor: Descriptor) throws -> MemoryChunk where Descriptor.Result: SharedPointerHandleStorageProtocol, Descriptor.Result.SharedPointerHandle.Pointee: MemoryBacked {
        var allocationCreateInfo = VmaAllocationCreateInfo()

        var allocationHandle: VmaAllocation? = nil
        var allocationInfo: VmaAllocationInfo = VmaAllocationInfo()

        try vulkanInvoke {
            Descriptor.Result.SharedPointerHandle.Pointee.vmaAllocFunction(handle, memoryBacked.pointer, &allocationCreateInfo, &allocationHandle, &allocationInfo)
        }

        let allocationHandlePointer = SharedPointer(with: allocationHandle!) { [unowned self] in
            vmaFreeMemory(self.handle, $0)
        }

        let allocation = Allocation(handlePointer: allocationHandlePointer)

        return try VMAMemoryChunk(allocator: self, allocation: allocation, info: allocationInfo, memoryProperties: descriptor.requiredMemoryProperties)
    }
}
