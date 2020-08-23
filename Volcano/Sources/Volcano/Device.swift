//
//  Device.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

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

public final class Device: VulkanEntity<SmartPointer<VkDevice_T>> {
    public let surface: Surface
    
    public let graphicsQueueFamilyIndex: Int
    public let presentationQueueFamilyIndex: Int
    
    public internal(set) lazy var graphicsQueue: Queue = {
        do {
            return try Queue(device: self, familyIndex: graphicsQueueFamilyIndex, queueIndex: 0)
        } catch {
            fatalError("Failed to retrieve graphics from vulkan with error: \(error)")
        }
    }()
    
    public internal(set) lazy var presentationQueue: Queue = {
        do {
            return try Queue(device: self, familyIndex: presentationQueueFamilyIndex, queueIndex: 0)
        } catch {
            fatalError("Failed to retrieve gresentation from vulkan with error: \(error)")
        }
    }()
    
    internal let vkCreateSwapchainKHR: PFN_vkCreateSwapchainKHR
    internal let vkDestroySwapchainKHR: PFN_vkDestroySwapchainKHR
    internal let vkGetSwapchainImagesKHR: PFN_vkGetSwapchainImagesKHR
    internal let vkAcquireNextImageKHR: PFN_vkAcquireNextImageKHR
    internal let vkQueuePresentKHR: PFN_vkQueuePresentKHR
    
    public init(surface: Surface) throws {
        self.surface = surface
        let physicalDevice = surface.physicalDevice
        
        var info = VkDeviceCreateInfo()
        info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
        info.flags = 0
        
        var enabledFeatures = physicalDevice.features
        withUnsafePointer(to: &enabledFeatures) {
            info.pEnabledFeatures = $0
        }
        
        let queuePrioririesPointer = SmartPointer<Float>.allocate(capacity: 1)
        queuePrioririesPointer.pointer.initialize(to: 1.0)
        
        let queueFamiliesProperties = physicalDevice.queueFamiliesProperties.enumerated()
        
        let presentationQueueOffsetPair = try queueFamiliesProperties.first {
            try surface.supportsPresenting(onQueueFamilyIndex: $0.offset)
        }
        
        guard let presentationQueueFamilyIndex = presentationQueueOffsetPair?.offset else {
            fatalError("No queues that support image presenting")
        }
        
        self.presentationQueueFamilyIndex = presentationQueueFamilyIndex
        
        let graphicsQueueOffsetPair = queueFamiliesProperties.first {
            $0.element.isGraphics
        }
        
        guard let graphicsQueueFamilyIndex = graphicsQueueOffsetPair?.offset else {
            fatalError("No queues that support rendering")
        }
        
        self.graphicsQueueFamilyIndex = graphicsQueueFamilyIndex
        
        let deviceQueueCreationInfos: [VkDeviceQueueCreateInfo] = try queueFamiliesProperties
            .filter { return try $0.element.isGraphics || surface.supportsPresenting(onQueueFamilyIndex: $0.offset) }
            .map {
                var result = VkDeviceQueueCreateInfo()
                result.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
                result.flags = 0
                result.queueFamilyIndex = CUnsignedInt($0.offset)
                result.queueCount = 1
                result.pQueuePriorities = UnsafePointer(queuePrioririesPointer.pointer)
                return result
            }
        
        info.queueCreateInfoCount = CUnsignedInt(deviceQueueCreationInfos.count)
        deviceQueueCreationInfos.withUnsafeBufferPointer {
            info.pQueueCreateInfos = $0.baseAddress
        }
        
        let extensions = [VK_KHR_SWAPCHAIN_EXTENSION_NAME]
        let extensionsCStrings = extensions.cStrings
        
        let extensionsPointer = SmartPointer<UnsafePointer<Int8>?>.allocate(capacity: extensionsCStrings.count)
        
        extensionsCStrings.enumerated().forEach {
            extensionsPointer.pointer[$0.offset] = UnsafePointer($0.element.pointer)
        }
        
        info.enabledExtensionCount = CUnsignedInt(extensionsCStrings.count)
        info.ppEnabledExtensionNames = UnsafePointer(extensionsPointer.pointer)
        
        let handlePointer = try physicalDevice.create(with: info)
        
        vkCreateSwapchainKHR = try handlePointer.loadFunction(named: "vkCreateSwapchainKHR")
        vkDestroySwapchainKHR = try handlePointer.loadFunction(named: "vkDestroySwapchainKHR")
        vkGetSwapchainImagesKHR = try handlePointer.loadFunction(named: "vkGetSwapchainImagesKHR")
        vkAcquireNextImageKHR = try handlePointer.loadFunction(named: "vkAcquireNextImageKHR")
        vkQueuePresentKHR = try handlePointer.loadFunction(named: "vkQueuePresentKHR")
        
        try super.init(instance: physicalDevice.instance, handlePointer: handlePointer)
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
}

public extension Device {
    func shader(named name: String, in bundle: Bundle? = nil) throws -> Shader {
        return try Shader(named: name, in: bundle, device: self)
    }
}
