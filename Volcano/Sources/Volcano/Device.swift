//
//  Device.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

internal extension SmartPointer where Pointee == VkDevice_T {
    func loadFunction<Function>(named name: String) throws -> Function {
        guard let result = cVulkanGetDeviceProcAddr(pointer, name) else {
            throw VulkanError.deviceFunctionNotFound(name)
        }
        
        return unsafeBitCast(result, to: Function.self)
    }
}

extension VkDevice_T: EntityFactory {}
extension VkDevice_T: DataLoader {}

public final class Device: VulkanPhysicalDeviceEntity<SmartPointer<VkDevice_T>> {
    public internal(set) var queuesByFamilyIndex: [CUnsignedInt: [Queue]] = [:]
    public internal(set) lazy var allQueues: [Queue] = queuesByFamilyIndex.flatMap { $0.value }
    
    internal let vkCreateSwapchainKHR: PFN_vkCreateSwapchainKHR
    internal let vkDestroySwapchainKHR: PFN_vkDestroySwapchainKHR
    internal let vkGetSwapchainImagesKHR: PFN_vkGetSwapchainImagesKHR
    internal let vkAcquireNextImageKHR: PFN_vkAcquireNextImageKHR
    internal let vkQueuePresentKHR: PFN_vkQueuePresentKHR

    public init(physicalDevice: PhysicalDevice, queueRequests: [QueueRequest] = [.default]) throws {
        let enabledFeatures = physicalDevice.features

        let extensions = [VK_KHR_SWAPCHAIN_EXTENSION_NAME].cStrings
        let extensionsNamesPointers: [UnsafePointer<Int8>?] = extensions.map { UnsafePointer($0.pointer) }

        let processedQueueRequests = try processQueueRequests(from: queueRequests, familiesDescriptors: physicalDevice.queueFamiliesDescriptors)

        let handlePointer: SmartPointer<VkDevice_T> = try withUnsafePointer(to: enabledFeatures) { enabledFeatures in
            try extensionsNamesPointers.withUnsafeBufferPointer { extensions in
                try processedQueueRequests.withUnsafeDeviceQueueCreateInfoBufferPointer { deviceQueueCreateInfos in
                    var info = VkDeviceCreateInfo()

                    info.sType = .deviceCreateInfo
                    info.flags = 0

                    info.pEnabledFeatures = enabledFeatures

                    info.enabledExtensionCount = CUnsignedInt(extensions.count)
                    info.ppEnabledExtensionNames = extensions.baseAddress!
                    
                    info.queueCreateInfoCount = CUnsignedInt(deviceQueueCreateInfos.count)
                    info.pQueueCreateInfos = deviceQueueCreateInfos.baseAddress!

                    return try physicalDevice.create(with: &info)
                }
            }
        }

        vkCreateSwapchainKHR = try handlePointer.loadFunction(named: "vkCreateSwapchainKHR")
        vkDestroySwapchainKHR = try handlePointer.loadFunction(named: "vkDestroySwapchainKHR")
        vkGetSwapchainImagesKHR = try handlePointer.loadFunction(named: "vkGetSwapchainImagesKHR")
        vkAcquireNextImageKHR = try handlePointer.loadFunction(named: "vkAcquireNextImageKHR")
        vkQueuePresentKHR = try handlePointer.loadFunction(named: "vkQueuePresentKHR")

        try super.init(physicalDevice: physicalDevice, handlePointer: handlePointer)

        for queueRequest in processedQueueRequests {
            let familyIndex = queueRequest.index

            var queuesArray: [Queue] = []

            for queueIndex in 0..<queueRequest.priorities.count {
                queuesArray.append(try Queue(device: self, familyIndex: familyIndex, queueIndex: queueIndex, type: queueRequest.type))
            }

            queuesByFamilyIndex[CUnsignedInt(familyIndex)] = queuesArray
        }
    }
    
    public func waitForIdle() throws {
        try vulkanInvoke {
            vkDeviceWaitIdle(handle)
        }
    }
    
    public func wait(forFences fences: [Fence], waitForAll: Bool = true, timeout: UInt64 = .max) throws {
        var handles: [VkFence?] = fences.map { return $0.handle }

        try vulkanInvoke {
            vkWaitForFences(handle, CUnsignedInt(handles.count), &handles, waitForAll.vkBool, timeout)
        }
    }
    
    public func reset(fences: [Fence]) throws {
        var handles: [VkFence?] = fences.map { return $0.handle }

        try vulkanInvoke {
            vkResetFences(handle, CUnsignedInt(handles.count), &handles)
        }
    }
    
    internal func memoryRequirements(for bufferHandle: SmartPointer<VkBuffer_T>) throws -> VkMemoryRequirements {
        var result = VkMemoryRequirements()

        try vulkanInvoke {
            vkGetBufferMemoryRequirements(handle, bufferHandle.pointer, &result)
        }
        
        return result
    }
}

public extension Device {
    func shader(named name: String, in bundle: Bundle? = nil) throws -> Shader {
        return try Shader(named: name, in: bundle, device: self)
    }
}

public extension Device {
    func allocateMemory(info: UnsafePointer<VkMemoryAllocateInfo>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SmartPointer<VkDeviceMemory_T> {
        var memory: VkDeviceMemory? = nil

        try vulkanInvoke {
            vkAllocateMemory(handle, info, callbacks, &memory)
        }

        // palkovnik:TODO:Validate if this has to retain the thing. Maybe it needs to
        return SmartPointer(with: memory!) { [unowned self] in
            vkFreeMemory(self.handle, $0, callbacks)
        }
    }
}
