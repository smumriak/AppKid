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
    public internal(set) lazy var allQueues: [Queue] = queuesByFamilyIndex.values.flatMap { $0 }.sorted { $0.type < $1.type }
    private var _memoryAllocator: MemoryAllocator? = nil
    public var memoryAllocator: MemoryAllocator { _memoryAllocator! }
    
    internal let vkCreateSwapchainKHR: PFN_vkCreateSwapchainKHR
    internal let vkDestroySwapchainKHR: PFN_vkDestroySwapchainKHR
    internal let vkGetSwapchainImagesKHR: PFN_vkGetSwapchainImagesKHR
    internal let vkAcquireNextImageKHR: PFN_vkAcquireNextImageKHR
    internal let vkQueuePresentKHR: PFN_vkQueuePresentKHR
    internal let vkGetSemaphoreCounterValueKHR: PFN_vkGetSemaphoreCounterValueKHR
    internal let vkWaitSemaphoresKHR: PFN_vkWaitSemaphoresKHR
    internal let vkSignalSemaphoreKHR: PFN_vkSignalSemaphoreKHR

    public init(physicalDevice: PhysicalDevice, queueRequests: [QueueRequest] = [.default], extensions: Set<VulkanExtensionName> = [], memoryAllocatorClass: MemoryAllocator.Type = DirectMemoryAllocator.self) throws {
        var features = physicalDevice.features
        features.samplerAnisotropy = true.vkBool

        // let features11 = physicalDevice.features11
        // var features12 = physicalDevice.features12
        // features12.timelineSemaphore = true.vkBool

        var features2 = physicalDevice.features2
        features2.features = features

        var extensions = extensions
        extensions.formUnion([.timelineSemaphore])

        let processedQueueRequests = try processQueueRequests(from: queueRequests, familiesDescriptors: physicalDevice.queueFamiliesDescriptors)
        var timelineSemaphoreFeatures = VkPhysicalDeviceTimelineSemaphoreFeatures.new()
        timelineSemaphoreFeatures.timelineSemaphore = true.vkBool

        let handlePointer: SmartPointer<VkDevice_T> =
            try extensions.map { $0.rawValue }.withUnsafeNullableCStringsBufferPointer { extensions in
                return try processedQueueRequests.withUnsafeDeviceQueueCreateInfoBufferPointer { deviceQueueCreateInfos in
                    var info = VkDeviceCreateInfo.new()
                    info.flags = 0

                    info.enabledExtensionCount = CUnsignedInt(extensions.count)
                    info.ppEnabledExtensionNames = extensions.baseAddress!
                    
                    info.queueCreateInfoCount = CUnsignedInt(deviceQueueCreateInfos.count)
                    info.pQueueCreateInfos = deviceQueueCreateInfos.baseAddress!

                    let chain = VulkanStructureChain(root: info)
                    // chain.append(features12)
                    // chain.append(features11)
                    chain.append(timelineSemaphoreFeatures)
                    chain.append(features2)
        
                    return try physicalDevice.create(with: chain)
                }
            }

        vkCreateSwapchainKHR = try handlePointer.loadFunction(named: "vkCreateSwapchainKHR")
        vkDestroySwapchainKHR = try handlePointer.loadFunction(named: "vkDestroySwapchainKHR")
        vkGetSwapchainImagesKHR = try handlePointer.loadFunction(named: "vkGetSwapchainImagesKHR")
        vkAcquireNextImageKHR = try handlePointer.loadFunction(named: "vkAcquireNextImageKHR")
        vkQueuePresentKHR = try handlePointer.loadFunction(named: "vkQueuePresentKHR")
        vkGetSemaphoreCounterValueKHR = try handlePointer.loadFunction(named: "vkGetSemaphoreCounterValueKHR")
        vkWaitSemaphoresKHR = try handlePointer.loadFunction(named: "vkWaitSemaphoresKHR")
        vkSignalSemaphoreKHR = try handlePointer.loadFunction(named: "vkSignalSemaphoreKHR")

        try super.init(physicalDevice: physicalDevice, handlePointer: handlePointer)

        _memoryAllocator = try memoryAllocatorClass.init(device: self)

        for queueRequest in processedQueueRequests {
            let familyIndex = queueRequest.index

            var queuesArray: [Queue] = []

            for queueIndex in 0..<queueRequest.priorities.count {
                try queuesArray.append(Queue(device: self, familyIndex: familyIndex, queueIndex: queueIndex, type: queueRequest.type))
            }

            queuesByFamilyIndex[CUnsignedInt(familyIndex)] = queuesArray
        }
    }
    
    public func waitForIdle() throws {
        try vulkanInvoke {
            vkDeviceWaitIdle(handle)
        }
    }

    internal func memoryRequirements<T: SmartPointerProtocol>(for handle: T) throws -> VkMemoryRequirements where T.Pointee: MemoryBacked {
        var result = VkMemoryRequirements()

        try vulkanInvoke {
            T.Pointee.requirementsFunction(self.handle, handle.pointer, &result)
        }
        
        return result
    }
}

public extension Device {
    func shader(named name: String, entryPoint: String = "main", in bundle: Bundle? = nil, subdirectory: String? = nil) throws -> Shader {
        return try Shader(named: name, entryPoint: entryPoint, in: bundle, subdirectory: subdirectory, device: self)
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
