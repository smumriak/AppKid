//
//  MemoryAllocator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 06.07.2020.
//

import TinyFoundation
import CVulkan

public protocol MemoryAllocateDescriptor {
    associatedtype Result
    associatedtype Info: SimpleEntityInfo where Info.Result: MemoryBacked, Info.Parent == VkDevice.Pointee

    var requiredMemoryProperties: VkMemoryPropertyFlagBits { get }
    var preferredMemoryProperties: VkMemoryPropertyFlagBits { get }

    func withUnsafeEntityCreateInfoPointer<T>(_ body: (UnsafePointer<Info>) throws -> (T)) rethrows -> T

    func createEntity(device: Device, handle: SharedPointer<Info.Result>, memoryChunk: MemoryChunk) throws -> Result
}

extension ImageDescriptor: MemoryAllocateDescriptor {
    public typealias Result = Image
    public typealias Info = VkImageCreateInfo

    public func withUnsafeEntityCreateInfoPointer<T>(_ body: (UnsafePointer<Info>) throws -> (T)) rethrows -> T {
        try withUnsafeImageCreateInfoPointer(body)
    }

    public func createEntity(device: Device, handle: SharedPointer<Info.Result>, memoryChunk: MemoryChunk) throws -> Image {
        return try Image(device: device, handle: handle, format: format)
    }
}

extension BufferDescriptor: MemoryAllocateDescriptor {
    public typealias Result = Buffer
    public typealias Info = VkBufferCreateInfo

    public func withUnsafeEntityCreateInfoPointer<T>(_ body: (UnsafePointer<Info>) throws -> (T)) rethrows -> T {
        try withUnsafeBufferCreateInfoPointer(body)
    }

    public func createEntity(device: Device, handle: SharedPointer<Info.Result>, memoryChunk: MemoryChunk) throws -> Buffer {
        return try Buffer(device: device, handle: handle, size: size, usage: usage, sharingMode: sharingMode, memoryChunk: memoryChunk, shouldBind: true)
    }
}

public protocol MemoryAllocator {
    var device: Device { get }

    init(device: Device) throws

    func create<Descriptor: MemoryAllocateDescriptor>(with descriptor: Descriptor) throws -> (result: Descriptor.Result, memoryChunk: MemoryChunk)
    func allocate<Descriptor: MemoryAllocateDescriptor>(for memoryBacked: Descriptor.Result.Handle, descriptor: Descriptor) throws -> MemoryChunk where Descriptor.Result: HandleStorage, Descriptor.Result.Handle: SmartPointer, Descriptor.Result.Handle.Pointee: MemoryBacked
}

public class DirectMemoryAllocator: MemoryAllocator {
    public internal(set) unowned var device: Device

    public required init(device: Device) throws {
        self.device = device
    }

    public func create<Descriptor: MemoryAllocateDescriptor>(with descriptor: Descriptor) throws -> (result: Descriptor.Result, memoryChunk: MemoryChunk) {
        fatalError()
    }

    public func allocate<Descriptor: MemoryAllocateDescriptor>(for memoryBacked: Descriptor.Result.Handle, descriptor: Descriptor) throws -> MemoryChunk where Descriptor.Result: HandleStorage, Descriptor.Result.Handle: SmartPointer, Descriptor.Result.Handle.Pointee: MemoryBacked {
        let memoryTypes = device.physicalDevice.memoryTypes

        let memoryRequirements = try device.memoryRequirements(for: memoryBacked)

        let memoryTypeAndIndexOptional = memoryTypes.enumerated().first { offset, element -> Bool in
            let flags = VkMemoryPropertyFlagBits(rawValue: element.propertyFlags)

            return (memoryRequirements.memoryTypeBits & (1 << offset)) != 0 && flags.contains(descriptor.requiredMemoryProperties)
        }

        guard let (memoryIndex, memoryType) = memoryTypeAndIndexOptional else {
            throw VulkanError.noSuitableMemoryTypeAvailable
        }

        return try MemoryChunk(device: device, size: memoryRequirements.size, memoryIndex: CUnsignedInt(memoryIndex), properties: VkMemoryPropertyFlagBits(rawValue: memoryType.propertyFlags))
    }
}
