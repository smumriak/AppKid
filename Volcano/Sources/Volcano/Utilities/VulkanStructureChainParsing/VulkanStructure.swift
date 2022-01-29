//
//  VulkanStructure.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2021.
//

import TinyFoundation
import CVulkan

public protocol VulkanBaseStructure: PublicInitializable {
    var sType: VkStructureType { get set }
}

extension VkBaseInStructure: VulkanBaseStructure {}
extension VkBaseOutStructure: VulkanBaseStructure {}

public protocol VulkanStructure: VulkanBaseStructure {
    static var type: VkStructureType { get }
}

public protocol VulkanChainableStructure: VulkanStructure {
    var pNext: UnsafeRawPointer! { get set }
}

public extension VulkanChainableStructure {
    mutating func withUnsafeRawPointer<R>(_ body: (UnsafeRawPointer) throws -> (R)) rethrows -> R {
        try withUnsafePointer(to: &self) {
            try body(UnsafeRawPointer($0))
        }
    }
}

public protocol VulkanInStructure: VulkanChainableStructure {
    var pNext: UnsafeRawPointer! { get set }
}

public protocol VulkanOutStructure: VulkanChainableStructure {
    var pNext: UnsafeMutableRawPointer! { get set }
}

public extension VulkanOutStructure {
    var pNext: UnsafeRawPointer! {
        get {
            return UnsafeRawPointer(pNext)
        }
        set {
            pNext = UnsafeMutableRawPointer(mutating: newValue)
        }
    }
}

public extension VulkanStructure {
    @_transparent
    static func new() -> Self {
        var result = Self()
        result.sType = Self.type
        return result
    }
}

internal extension UnsafePointer where Pointee: VulkanOutStructure {
    var vulkanIn: UnsafePointer<VkBaseInStructure> {
        return UnsafeRawPointer(self).assumingMemoryBound(to: VkBaseInStructure.self)
    }
}

internal extension UnsafeMutablePointer where Pointee: VulkanOutStructure {
    var vulkanIn: UnsafePointer<VkBaseInStructure> {
        return UnsafeRawPointer(self).assumingMemoryBound(to: VkBaseInStructure.self)
    }

    var vulkanOut: UnsafeMutablePointer<VkBaseInStructure> {
        return UnsafeMutableRawPointer(self).assumingMemoryBound(to: VkBaseInStructure.self)
    }
}
