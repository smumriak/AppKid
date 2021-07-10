//
//  DescriptorSet.swift
//  Volcano
//
//  Created by Serhii Mumriak on 07.07.2021.
//

import TinyFoundation
import CVulkan

public final class DescriptorPool: VulkanDeviceEntity<SmartPointer<VkDescriptorPool_T>> {
    public let maxSets: UInt
    public init(device: Device, sizes: [VkDescriptorPoolSize], maxSets: UInt) throws {
        assert(!sizes.isEmpty)

        self.maxSets = maxSets

        let handlePointer: SmartPointer<VkDescriptorPool_T> = try sizes.withUnsafeBufferPointer { sizes in
            var info = VkDescriptorPoolCreateInfo()
            info.sType = .descriptorPoolCreateInfo
            info.poolSizeCount = CUnsignedInt(sizes.count)
            info.pPoolSizes = sizes.baseAddress!
            info.maxSets = CUnsignedInt(maxSets)

            return try device.create(with: &info)
        }

        try super.init(device: device, handlePointer: handlePointer)
    }

    public func allocate(with layout: DescriptorSetLayout) throws -> DescriptorSet {
        let result: VkDescriptorSet = try [layout].optionalPointers()
            .withUnsafeBufferPointer { layouts in
                var info = VkDescriptorSetAllocateInfo()
                info.sType = .descriptorSetAllocateInfo
                info.descriptorPool = handle
                info.descriptorSetCount = CUnsignedInt(layouts.count)
                info.pSetLayouts = layouts.baseAddress!
                var result: VkDescriptorSet? = nil

                try vulkanInvoke {
                    vkAllocateDescriptorSets(device.handle, &info, &result)
                }

                return result!
            }

        return DescriptorSet(pool: self, handle: result)
    }
}

public final class DescriptorSetLayout: VulkanDeviceEntity<SmartPointer<VkDescriptorSetLayout_T>> {
    public init(device: Device, bindings: [VkDescriptorSetLayoutBinding]) throws {
        let handlePointer: SmartPointer<VkDescriptorSetLayout_T> = try bindings.withUnsafeBufferPointer { bindings in
            var info = VkDescriptorSetLayoutCreateInfo()
            info.sType = .descriptorSetLayoutCreateInfo
            info.bindingCount = CUnsignedInt(bindings.count)
            info.pBindings = bindings.baseAddress!

            return try device.create(with: &info)
        }

        try super.init(device: device, handlePointer: handlePointer)
    }
}

public final class DescriptorSet: HandleStorageProtocol, Hashable {
    public let pool: DescriptorPool
    public let handle: VkDescriptorSet

    internal init(pool: DescriptorPool, handle: VkDescriptorSet) {
        self.pool = pool
        self.handle = handle
    }

    public func hash(into hasher: inout Hasher) {
        handle.hash(into: &hasher)
    }

    public static func == (lhs: DescriptorSet, rhs: DescriptorSet) -> Bool {
        lhs.handle == rhs.handle
    }
}
