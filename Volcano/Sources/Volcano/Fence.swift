//
//  Fence.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import TinyFoundation
import CVulkan

public final class Fence: VulkanDeviceEntity<SmartPointer<VkFence_T>> {
    public init(device: Device, flags: VkFenceCreateFlagBits = []) throws {
        var info = VkFenceCreateInfo(sType: .fenceCreateInfo, pNext: nil, flags: flags.rawValue)
        
        let handlePointer = try device.create(with: &info)
        
        try super.init(device: device, handlePointer: handlePointer)
    }
    
    public var isSignaled: Bool {
        get throws {
            let result = vkGetFenceStatus(device.handle, handle)
        
            switch result {
                case .success: return true
                case .notReady: return false
                default: throw VulkanError.badResult(result)
            }
        }
    }
    
    public func wait(timeout: UInt64 = .max) throws {
        var handleOptional: VkFence? = handle

        try vulkanInvoke {
            vkWaitForFences(device.handle, 1, &handleOptional, true.vkBool, timeout)
        }
    }
    
    public func reset() throws {
        var handleOptional: VkFence? = handle

        try vulkanInvoke {
            vkResetFences(device.handle, 1, &handleOptional)
        }
    }
}

public extension Device {
    func wait(for fences: [Fence], waitForAll: Bool = true, timeout: UInt64 = .max) throws {
        try fences.optionalHandles().withUnsafeBufferPointer { fences in
            try vulkanInvoke {
                vkWaitForFences(handle, CUnsignedInt(fences.count), fences.baseAddress!, waitForAll.vkBool, timeout)
            }
        }
    }
    
    func reset(fences: [Fence]) throws {
        try fences.optionalHandles().withUnsafeBufferPointer { fences in
            try vulkanInvoke {
                vkResetFences(handle, CUnsignedInt(fences.count), fences.baseAddress!)
            }
        }
    }
}
