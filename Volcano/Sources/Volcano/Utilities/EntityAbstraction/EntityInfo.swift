//
//  EntityInfo.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2020.
//

import CVulkan

public protocol EntityInfo: VulkanChainableStructure {
    associatedtype Parent: EntityFactory & VkEntity
    associatedtype Result: VkEntity

    typealias CreateFunction = (UnsafeMutablePointer<Parent>?, UnsafePointer<Self>?, UnsafePointer<VkAllocationCallbacks>?, UnsafeMutablePointer<UnsafeMutablePointer<Result>?>?) -> (VkResult)
    static var createFunction: CreateFunction { get }

    typealias DeleteFunction = (UnsafeMutablePointer<Parent>?, UnsafeMutablePointer<Result>?, UnsafePointer<VkAllocationCallbacks>?) -> ()
    static var deleteFunction: DeleteFunction { get }
}

#if os(Linux)
    public typealias VkXlibSurfaceCreateInfoKHR = CVulkan.VkXlibSurfaceCreateInfoKHR

    extension VkXlibSurfaceCreateInfoKHR: EntityInfo {
        public typealias Parent = VkInstance.Pointee
        public typealias Result = VkSurfaceKHR.Pointee
        public static let createFunction: CreateFunction = vkCreateXlibSurfaceKHR
        public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
    }

#elseif os(macOS)
    public typealias VkMacOSSurfaceCreateInfoMVK = CVulkan.VkMacOSSurfaceCreateInfoMVK

    extension VkMacOSSurfaceCreateInfoMVK: EntityInfo {
        public typealias Parent = VkInstance.Pointee
        public typealias Result = VkSurfaceKHR.Pointee
        public static let createFunction: CreateFunction = vkCreateMacOSSurfaceMVK
        public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
    }
#endif

public typealias VkDeviceCreateInfo = CVulkan.VkDeviceCreateInfo

extension VkDeviceCreateInfo: EntityInfo {
    public typealias Parent = VkPhysicalDevice.Pointee
    public typealias Result = VkDevice.Pointee
    public static let createFunction: CreateFunction = vkCreateDevice
    public static let deleteFunction: DeleteFunction = { physicalDevice, device, allocator in
        vkDestroyDevice(device, allocator)
    }
}

public typealias VkShaderModuleCreateInfo = CVulkan.VkShaderModuleCreateInfo

extension VkShaderModuleCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkShaderModule.Pointee
    public static let createFunction: CreateFunction = vkCreateShaderModule
    public static let deleteFunction: DeleteFunction = vkDestroyShaderModule
}

public typealias VkCommandPoolCreateInfo = CVulkan.VkCommandPoolCreateInfo

extension VkCommandPoolCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkCommandPool.Pointee
    public static let createFunction: CreateFunction = vkCreateCommandPool
    public static let deleteFunction: DeleteFunction = vkDestroyCommandPool
}

public typealias VkFenceCreateInfo = CVulkan.VkFenceCreateInfo

extension VkFenceCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkFence.Pointee
    public static let createFunction: CreateFunction = vkCreateFence
    public static let deleteFunction: DeleteFunction = vkDestroyFence
}

public typealias VkSwapchainCreateInfoKHR = CVulkan.VkSwapchainCreateInfoKHR

extension VkSwapchainCreateInfoKHR: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkSwapchainKHR.Pointee
    public static let createFunction: CreateFunction = vkCreateSwapchainKHR
    public static let deleteFunction: DeleteFunction = vkDestroySwapchainKHR
}

public typealias VkImageViewCreateInfo = CVulkan.VkImageViewCreateInfo

extension VkImageViewCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkImageView.Pointee
    public static let createFunction: CreateFunction = vkCreateImageView
    public static let deleteFunction: DeleteFunction = vkDestroyImageView
}

public typealias VkPipelineLayoutCreateInfo = CVulkan.VkPipelineLayoutCreateInfo

extension VkPipelineLayoutCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkPipelineLayout.Pointee
    public static let createFunction: CreateFunction = vkCreatePipelineLayout
    public static let deleteFunction: DeleteFunction = vkDestroyPipelineLayout
}

public typealias VkRenderPassCreateInfo = CVulkan.VkRenderPassCreateInfo

extension VkRenderPassCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction: CreateFunction = vkCreateRenderPass
    public static let deleteFunction: DeleteFunction = vkDestroyRenderPass
}

public typealias VkFramebufferCreateInfo = CVulkan.VkFramebufferCreateInfo

extension VkFramebufferCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkFramebuffer.Pointee
    public static let createFunction: CreateFunction = vkCreateFramebuffer
    public static let deleteFunction: DeleteFunction = vkDestroyFramebuffer
}

public typealias VkSemaphoreCreateInfo = CVulkan.VkSemaphoreCreateInfo

extension VkSemaphoreCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkSemaphore.Pointee
    public static let createFunction: CreateFunction = vkCreateSemaphore
    public static let deleteFunction: DeleteFunction = vkDestroySemaphore
}

public typealias VkSamplerCreateInfo = CVulkan.VkSamplerCreateInfo

extension VkSamplerCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkSampler.Pointee
    public static let createFunction: CreateFunction = vkCreateSampler
    public static let deleteFunction: DeleteFunction = vkDestroySampler
}

public typealias VkEventCreateInfo = CVulkan.VkEventCreateInfo

extension VkEventCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkEvent.Pointee
    public static let createFunction: CreateFunction = vkCreateEvent
    public static let deleteFunction: DeleteFunction = vkDestroyEvent
}

public typealias VkQueryPoolCreateInfo = CVulkan.VkQueryPoolCreateInfo

extension VkQueryPoolCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkQueryPool.Pointee
    public static let createFunction: CreateFunction = vkCreateQueryPool
    public static let deleteFunction: DeleteFunction = vkDestroyQueryPool
}

public typealias VkBufferCreateInfo = CVulkan.VkBufferCreateInfo

extension VkBufferCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkBuffer.Pointee
    public static let createFunction: CreateFunction = vkCreateBuffer
    public static let deleteFunction: DeleteFunction = vkDestroyBuffer
}

public typealias VkBufferViewCreateInfo = CVulkan.VkBufferViewCreateInfo

extension VkBufferViewCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkBufferView.Pointee
    public static let createFunction: CreateFunction = vkCreateBufferView
    public static let deleteFunction: DeleteFunction = vkDestroyBufferView
}

public typealias VkImageCreateInfo = CVulkan.VkImageCreateInfo

extension VkImageCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkImage.Pointee
    public static let createFunction: CreateFunction = vkCreateImage
    public static let deleteFunction: DeleteFunction = vkDestroyImage
}

public typealias VkDescriptorSetLayoutCreateInfo = CVulkan.VkDescriptorSetLayoutCreateInfo

extension VkDescriptorSetLayoutCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkDescriptorSetLayout.Pointee
    public static let createFunction: CreateFunction = vkCreateDescriptorSetLayout
    public static let deleteFunction: DeleteFunction = vkDestroyDescriptorSetLayout
}

public typealias VkDescriptorPoolCreateInfo = CVulkan.VkDescriptorPoolCreateInfo

extension VkDescriptorPoolCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkDescriptorPool.Pointee
    public static let createFunction: CreateFunction = vkCreateDescriptorPool
    public static let deleteFunction: DeleteFunction = vkDestroyDescriptorPool
}

public typealias VkRenderPassCreateInfo2 = CVulkan.VkRenderPassCreateInfo2

extension VkRenderPassCreateInfo2: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction: CreateFunction = vkCreateRenderPass2
    public static let deleteFunction: DeleteFunction = vkDestroyRenderPass
}
