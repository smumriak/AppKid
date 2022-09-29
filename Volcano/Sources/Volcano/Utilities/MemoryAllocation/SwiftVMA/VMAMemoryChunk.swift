//
//  VMAMemoryChunk.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import TinyFoundation
import VulkanMemoryAllocatorAdapted

public class VMAMemoryChunk: MemoryChunk {
    public let allocator: VulkanMemoryAllocator
    public let allocation: VulkanMemoryAllocator.Allocation
    public internal(set) var currentlyMappedVMAPointer: UnsafeMutableRawPointer? = nil

    deinit {
        if currentlyMappedVMAPointer != nil {
            try? unmapData()
        }
    }

    public init(allocator: VulkanMemoryAllocator, allocation: VulkanMemoryAllocator.Allocation, info: VmaAllocationInfo, memoryProperties: VkMemoryPropertyFlagBits) throws {
        self.allocator = allocator
        self.allocation = allocation

        let handle = SharedPointer(with: info.deviceMemory!, deleter: .none)

        try super.init(device: allocator.device, handle: handle, parent: nil, offset: info.offset, size: info.size, properties: memoryProperties)
    }

    public override func mapData(_ offset: VkDeviceSize = 0) throws -> UnsafeMutableRawPointer {
        assert(currentlyMappedVMAPointer == nil, "Memory chunk is already mapped")

        try vulkanInvoke {
            vmaMapMemory(allocator.pointer, allocation.pointer, &currentlyMappedVMAPointer)
        }

        return currentlyMappedVMAPointer!
    }

    public override func unmapData() throws {
        assert(currentlyMappedVMAPointer != nil, "Memory chunk is not mapped")

        try vulkanInvoke {
            vmaUnmapMemory(allocator.pointer, allocation.pointer)
        }

        currentlyMappedVMAPointer = nil
    }

    public override func bind(to bindable: Buffer) throws {
        try bindPrivate(to: bindable)
    }

    public override func bind(to bindable: Image) throws {
        try bindPrivate(to: bindable)
    }

    private func bindPrivate<T: MemoryBindable>(to bindable: T) throws {
        try vulkanInvoke {
            T.vmaBindFunction(allocator.pointer, allocation.pointer, bindable.pointer)
        }
    }
}

public extension MemoryBacked {
    typealias VMAAllocFunction = (_ allocator: VmaAllocator, _ memoryBacked: UnsafeMutablePointer<Self>, _ createInfo: UnsafePointer<VmaAllocationCreateInfo>, _ result: UnsafeMutablePointer<VmaAllocation?>, _ allocationInfo: UnsafeMutablePointer<VmaAllocationInfo>?) -> (VkResult)
    static var vmaAllocFunction: VMAAllocFunction {
        switch self {
            case let SpecializedInfo as VkImage_T.Type:
                return SpecializedInfo.vmaAllocFunctionPrivate as! VMAAllocFunction

            case let SpecializedInfo as VkBuffer_T.Type:
                return SpecializedInfo.vmaAllocFunctionPrivate as! VMAAllocFunction

            default:
                fatalError("\(Swift.type(of: self as Any))  is not supported by Vulkan Memory Allocator")
        }
    }

    typealias VMABindFunction = (_ allocator: VmaAllocator, _ allocation: VmaAllocation, _ bindable: SharedPointer<Self>.Pointer) -> (VkResult)
    static var vmaBindFunction: VMABindFunction {
        switch self {
            case let SpecializedInfo as VkImage_T.Type:
                return SpecializedInfo.vmaBindFunctionPrivate as! VMABindFunction

            case let SpecializedInfo as VkBuffer_T.Type:
                return SpecializedInfo.vmaBindFunctionPrivate as! VMABindFunction

            default:
                fatalError("\(Swift.type(of: self as Any))  is not supported by Vulkan Memory Allocator")
        }
    }
}

public extension VkImage_T {
    static let vmaAllocFunctionPrivate: VMAAllocFunction = vmaAllocateMemoryForImage
    static let vmaBindFunctionPrivate: VMABindFunction = vmaBindImageMemory
}

public extension VkBuffer_T {
    static let vmaAllocFunctionPrivate: VMAAllocFunction = vmaAllocateMemoryForBuffer
    static let vmaBindFunctionPrivate: VMABindFunction = vmaBindBufferMemory
}

public extension SimpleEntityInfo {
    typealias VMACreateFunction = (_ allocator: VmaAllocator, _ info: UnsafePointer<Self>, _ allocationCreateInfo: UnsafePointer<VmaAllocationCreateInfo>, _ result: UnsafeMutablePointer<UnsafeMutablePointer<Self.Result>?>, _ allocation: UnsafeMutablePointer<VmaAllocation?>, _ allocationInfo: UnsafeMutablePointer<VmaAllocationInfo>) -> (VkResult)
    static var vmaCreateFunction: VMACreateFunction {
        switch self {
            case let SpecializedInfo as VkImageCreateInfo.Type:
                return SpecializedInfo.vmaCreateFunctionPrivate as! VMACreateFunction

            case let SpecializedInfo as VkBufferCreateInfo.Type:
                return SpecializedInfo.vmaCreateFunctionPrivate as! VMACreateFunction

            default:
                fatalError("\(Swift.type(of: self as Any))  is not supported by Vulkan Memory Allocator")
        }
    }
}

private extension VkImageCreateInfo {
    static let vmaCreateFunctionPrivate: VMACreateFunction = vmaCreateImage
}

private extension VkBufferCreateInfo {
    static let vmaCreateFunctionPrivate: VMACreateFunction = vmaCreateBuffer
}

public extension MemoryBindable {
    static var vmaBindFunction: Handle.Pointee.VMABindFunction {
        return Handle.Pointee.vmaBindFunction
    }
}

public extension MemoryAllocateDescriptor {
    func withUnsafeAllocationCreateInfoPointer<T>(_ body: (UnsafePointer<VmaAllocationCreateInfo>) throws -> (T)) rethrows -> T {
        let flags: VmaAllocationCreateFlagBits = [.dontBind]
        
        var info = VmaAllocationCreateInfo()
        info.flags = flags.rawValue
        info.usage = .unknown
        info.requiredFlags = requiredMemoryProperties.rawValue
        info.preferredFlags = preferredMemoryProperties.rawValue
        info.pool = nil
        info.pUserData = nil
        info.priority = 0

        return try body(&info)
    }
}
