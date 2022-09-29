//
//  Fence.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import TinyFoundation
import CVulkan

public final class Fence: DeviceEntity<VkFence_T> {
    public init(device: Device, flags: VkFenceCreateFlagBits = []) throws {
        var info = VkFenceCreateInfo(sType: .fenceCreateInfo, pNext: nil, flags: flags.rawValue)
        
        let handle = try device.create(with: &info)
        
        try super.init(device: device, handle: handle)
    }
    
    public var isSignaled: Bool {
        get throws {
            let result = vkGetFenceStatus(device.pointer, pointer)
        
            switch result {
                case .success: return true
                case .notReady: return false
                default: throw VulkanError.badResult(result)
            }
        }
    }
    
    public func wait(timeout: UInt64 = .max) throws {
        var handleOptional: VkFence? = pointer

        try vulkanInvoke {
            vkWaitForFences(device.pointer, 1, &handleOptional, true.vkBool, timeout)
        }
    }
    
    public func reset() throws {
        var handleOptional: VkFence? = pointer

        try vulkanInvoke {
            vkResetFences(device.pointer, 1, &handleOptional)
        }
    }
}

public extension Device {
    func wait(for fences: [Fence], waitForAll: Bool = true, timeout: UInt64 = .max) throws {
        try fences.optionalMutablePointers().withUnsafeBufferPointer { fences in
            try vulkanInvoke {
                vkWaitForFences(pointer, CUnsignedInt(fences.count), fences.baseAddress!, waitForAll.vkBool, timeout)
            }
        }
    }
    
    func reset(fences: [Fence]) throws {
        try fences.optionalMutablePointers().withUnsafeBufferPointer { fences in
            try vulkanInvoke {
                vkResetFences(pointer, CUnsignedInt(fences.count), fences.baseAddress!)
            }
        }
    }
}
