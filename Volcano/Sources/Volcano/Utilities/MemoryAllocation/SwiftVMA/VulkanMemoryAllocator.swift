//
//  VulkanMemoryAllocator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import TinyFoundation
import VulkanMemoryAllocatorAdapted

public class VulkanMemoryAllocator: SharedPointerStorage<VmaAllocator_T>, MemoryAllocator {
    public typealias Allocation = SharedPointerStorage<VmaAllocation_T>

    public internal(set) unowned var device: Device

    public required init(device: Device) throws {
        self.device = device

        let flags: VmaAllocatorCreateFlagBits = []

        var info = VmaAllocatorCreateInfo(
            flags: flags.rawValue,
            physicalDevice: device.physicalDevice.pointer,
            device: device.pointer,
            preferredLargeHeapBlockSize: 0,
            pAllocationCallbacks: nil,
            pDeviceMemoryCallbacks: nil,
            pHeapSizeLimit: nil,
            pVulkanFunctions: nil,
            instance: device.instance.pointer,
            vulkanApiVersion: (1 << 22) | (0 << 12) | 0,
            pTypeExternalMemoryHandleTypes: nil)

        var pointer: VmaAllocator? = nil
        try vulkanInvoke {
            vmaCreateAllocator(&info, &pointer)
        }

        let handle = SharedPointer(with: pointer!, deleter: .custom {
            vmaDestroyAllocator($0)
        })

        super.init(handle: handle)
    }

    public func create<Descriptor: MemoryAllocateDescriptor>(with descriptor: Descriptor) throws -> (result: Descriptor.Result, memoryChunk: MemoryChunk) {
        var entityHandle: UnsafeMutablePointer<Descriptor.Info.Result>? = nil
        var allocationHandle: VmaAllocation? = nil
        var allocationInfo: VmaAllocationInfo = VmaAllocationInfo()

        try descriptor.withUnsafeAllocationCreateInfoPointer { allocationCreateInfo in
            try descriptor.withUnsafeEntityCreateInfoPointer { entityCreateInfo in
                try vulkanInvoke {
                    Descriptor.Info.vmaCreateFunction(pointer, entityCreateInfo, allocationCreateInfo, &entityHandle, &allocationHandle, &allocationInfo)
                }
            }
        }

        let entityHandlePointer = SharedPointer(with: entityHandle!) { [unowned device] in
            Descriptor.Info.deleteFunction(device.pointer, $0, nil)
        }

        let allocationHandlePointer = SharedPointer(with: allocationHandle!) { [unowned self] in
            vmaFreeMemory(self.pointer, $0)
        }

        let allocation = Allocation(handle: allocationHandlePointer)
        
        let memoryChunk = try VMAMemoryChunk(allocator: self, allocation: allocation, info: allocationInfo, memoryProperties: descriptor.requiredMemoryProperties)

        let result = try descriptor.createEntity(device: device, handle: entityHandlePointer, memoryChunk: memoryChunk)

        return (result, memoryChunk)
    }

    public func allocate<Descriptor: MemoryAllocateDescriptor>(for memoryBacked: Descriptor.Result.Handle, descriptor: Descriptor) throws -> MemoryChunk where Descriptor.Result: HandleStorage, Descriptor.Result.Handle: SmartPointer, Descriptor.Result.Handle.Pointee: MemoryBacked {
        var allocationCreateInfo = VmaAllocationCreateInfo()

        var allocationHandle: VmaAllocation? = nil
        var allocationInfo: VmaAllocationInfo = VmaAllocationInfo()

        try vulkanInvoke {
            Descriptor.Result.Handle.Pointee.vmaAllocFunction(pointer, memoryBacked.pointer, &allocationCreateInfo, &allocationHandle, &allocationInfo)
        }

        let allocationHandlePointer = SharedPointer(with: allocationHandle!) { [unowned self] in
            vmaFreeMemory(self.pointer, $0)
        }

        let allocation = Allocation(handle: allocationHandlePointer)

        return try VMAMemoryChunk(allocator: self, allocation: allocation, info: allocationInfo, memoryProperties: descriptor.requiredMemoryProperties)
    }
}
