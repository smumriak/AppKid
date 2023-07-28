//
//  Device.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation

internal extension SharedPointer where Pointee == VkDevice_T {
    func loadFunction<Function>(named name: String) throws -> Function {
        guard let result = vkGetDeviceProcAddr(pointer, name) else {
            throw VulkanError.deviceFunctionNotFound(name)
        }
        
        return unsafeBitCast(result, to: Function.self)
    }
}

extension VkDevice_T: EntityFactory {}
extension VkDevice_T: DataLoader {}

public final class Device: PhysicalDeviceEntity<VkDevice_T> {
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

    public init(physicalDevice: PhysicalDevice, queueRequests: [QueueRequest] = [.default], extensions: Set<DeviceExtension> = [], memoryAllocatorClass: MemoryAllocator.Type = DirectMemoryAllocator.self) throws {
        var features = physicalDevice.features
        features.samplerAnisotropy = true.vkBool
        features.sampleRateShading = true.vkBool

        // let features11 = physicalDevice.features11
        // var features12 = physicalDevice.features12
        // features12.timelineSemaphore = true.vkBool

        var features2 = physicalDevice.features2
        features2.features = features

        var extensions = extensions
        extensions.formUnion([.timelineSemaphoreKhr])

        let processedQueueRequests = try processQueueRequests(from: queueRequests, familiesDescriptors: physicalDevice.queueFamiliesDescriptors)
        var timelineSemaphoreFeatures = VkPhysicalDeviceTimelineSemaphoreFeatures.new()
        timelineSemaphoreFeatures.timelineSemaphore = true.vkBool

        let handle: Handle = try extensions.map { $0.rawValue }.withUnsafeNullableCStringsBufferPointer { extensions in
            try processedQueueRequests.withUnsafeDeviceQueueCreateInfoBufferPointer { deviceQueueCreateInfos in
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

        vkCreateSwapchainKHR = try handle.loadFunction(named: "vkCreateSwapchainKHR")
        vkDestroySwapchainKHR = try handle.loadFunction(named: "vkDestroySwapchainKHR")
        vkGetSwapchainImagesKHR = try handle.loadFunction(named: "vkGetSwapchainImagesKHR")
        vkAcquireNextImageKHR = try handle.loadFunction(named: "vkAcquireNextImageKHR")
        vkQueuePresentKHR = try handle.loadFunction(named: "vkQueuePresentKHR")
        vkGetSemaphoreCounterValueKHR = try handle.loadFunction(named: "vkGetSemaphoreCounterValueKHR")
        vkWaitSemaphoresKHR = try handle.loadFunction(named: "vkWaitSemaphoresKHR")
        vkSignalSemaphoreKHR = try handle.loadFunction(named: "vkSignalSemaphoreKHR")

        try super.init(physicalDevice: physicalDevice, handle: handle)

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
            vkDeviceWaitIdle(pointer)
        }
    }

    internal func memoryRequirements<T: SmartPointer>(for handle: T) throws -> VkMemoryRequirements where T.Pointee: MemoryBacked {
        var result = VkMemoryRequirements()

        try vulkanInvoke {
            T.Pointee.requirementsFunction(self.pointer, handle.pointer, &result)
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
    func allocateMemory(info: UnsafePointer<VkMemoryAllocateInfo>, callbacks: UnsafePointer<VkAllocationCallbacks>? = nil) throws -> SharedPointer<VkDeviceMemory_T> {
        var memory: VkDeviceMemory? = nil

        try vulkanInvoke {
            vkAllocateMemory(pointer, info, callbacks, &memory)
        }

        // smumriak:TODO:Validate if this has to retain the thing. Maybe it needs to
        return SharedPointer(with: memory!) { [unowned self] in
            vkFreeMemory(self.pointer, $0, callbacks)
        }
    }
}
