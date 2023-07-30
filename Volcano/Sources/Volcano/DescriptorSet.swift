//
//  DescriptorSet.swift
//  Volcano
//
//  Created by Serhii Mumriak on 07.07.2021.
//

import TinyFoundation

public final class DescriptorPool: DeviceEntity<VkDescriptorPool_T> {
    public let maxSets: UInt
    public init(device: Device, sizes: [VkDescriptorPoolSize], maxSets: UInt) throws {
        assert(!sizes.isEmpty)

        self.maxSets = maxSets

        try super.init(info: VkDescriptorPoolCreateInfo.self, device: device) {
            (\.poolSizeCount, \.pPoolSizes) <- sizes
            \.maxSets <- maxSets
        }
    }

    public func allocate(with layout: DescriptorSetLayout) throws -> DescriptorSet {
        let result: VkDescriptorSet = try [layout].optionalMutablePointers()
            .withUnsafeBufferPointer { layouts in
                var info = VkDescriptorSetAllocateInfo.new()
                info.descriptorPool = pointer
                info.descriptorSetCount = CUnsignedInt(layouts.count)
                info.pSetLayouts = layouts.baseAddress!
                var result: VkDescriptorSet? = nil

                try vulkanInvoke {
                    vkAllocateDescriptorSets(device.pointer, &info, &result)
                }

                return result!
            }

        return DescriptorSet(pool: self, handle: result)
    }

    public func free(descriptorSet: DescriptorSet) throws {
        try [descriptorSet].optionalHandles().withUnsafeBufferPointer { descriptorSets in
            try vulkanInvoke {
                vkFreeDescriptorSets(device.pointer, pointer, CUnsignedInt(descriptorSets.count), descriptorSets.baseAddress!)
            }
        }
    }
}

public final class DescriptorSetLayout: DeviceEntity<VkDescriptorSetLayout_T> {
    public init(device: Device, bindings: [VkDescriptorSetLayoutBinding]) throws {
        try super.init(info: VkDescriptorSetLayoutCreateInfo.self, device: device) {
            (\.bindingCount, \.pBindings) <- bindings
        }
    }
}

public final class DescriptorSet: HandleStorage, Hashable {
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
