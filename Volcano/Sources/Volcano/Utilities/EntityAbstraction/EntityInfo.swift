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
    extension VkXlibSurfaceCreateInfoKHR: EntityInfo {
        public typealias Parent = VkInstance.Pointee
        public typealias Result = VkSurfaceKHR.Pointee
        public static let createFunction: CreateFunction = vkCreateXlibSurfaceKHR
        public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
    }

#elseif os(macOS) || os(iOS)
    // extension VkMetalSurfaceCreateInfoEXT: EntityInfo {
    //     public typealias Parent = VkInstance.Pointee
    //     public typealias Result = VkSurfaceKHR.Pointee
    //     public static let createFunction: CreateFunction = vkCreateMetalSurfaceEXT
    //     public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
    // }

    #if os(macOS)
        extension VkMacOSSurfaceCreateInfoMVK: EntityInfo {
            public typealias Parent = VkInstance.Pointee
            public typealias Result = VkSurfaceKHR.Pointee
            public static let createFunction: CreateFunction = vkCreateMacOSSurfaceMVK
            public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
        }

    #elseif os(iOS)
        extension VkIOSSurfaceCreateInfoMVK: EntityInfo {
            public typealias Parent = VkInstance.Pointee
            public typealias Result = VkSurfaceKHR.Pointee
            public static let createFunction: CreateFunction = vkCreateIOSSurfaceMVK
            public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
        }
    #endif
#endif

extension VkDeviceCreateInfo: EntityInfo {
    public typealias Parent = VkPhysicalDevice.Pointee
    public typealias Result = VkDevice.Pointee
    public static let createFunction: CreateFunction = vkCreateDevice
    public static let deleteFunction: DeleteFunction = { physicalDevice, device, allocator in
        vkDestroyDevice(device, allocator)
    }
}

extension VkShaderModuleCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkShaderModule.Pointee
    public static let createFunction: CreateFunction = vkCreateShaderModule
    public static let deleteFunction: DeleteFunction = vkDestroyShaderModule
}

extension VkCommandPoolCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkCommandPool.Pointee
    public static let createFunction: CreateFunction = vkCreateCommandPool
    public static let deleteFunction: DeleteFunction = vkDestroyCommandPool
}

extension VkFenceCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkFence.Pointee
    public static let createFunction: CreateFunction = vkCreateFence
    public static let deleteFunction: DeleteFunction = vkDestroyFence
}

extension VkSwapchainCreateInfoKHR: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkSwapchainKHR.Pointee
    public static let createFunction: CreateFunction = vkCreateSwapchainKHR
    public static let deleteFunction: DeleteFunction = vkDestroySwapchainKHR
}

extension VkImageViewCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkImageView.Pointee
    public static let createFunction: CreateFunction = vkCreateImageView
    public static let deleteFunction: DeleteFunction = vkDestroyImageView
}

extension VkPipelineLayoutCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkPipelineLayout.Pointee
    public static let createFunction: CreateFunction = vkCreatePipelineLayout
    public static let deleteFunction: DeleteFunction = vkDestroyPipelineLayout
}

extension VkRenderPassCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction: CreateFunction = vkCreateRenderPass
    public static let deleteFunction: DeleteFunction = vkDestroyRenderPass
}

extension VkFramebufferCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkFramebuffer.Pointee
    public static let createFunction: CreateFunction = vkCreateFramebuffer
    public static let deleteFunction: DeleteFunction = vkDestroyFramebuffer
}

extension VkSemaphoreCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkSemaphore.Pointee
    public static let createFunction: CreateFunction = vkCreateSemaphore
    public static let deleteFunction: DeleteFunction = vkDestroySemaphore
}

extension VkSamplerCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkSampler.Pointee
    public static let createFunction: CreateFunction = vkCreateSampler
    public static let deleteFunction: DeleteFunction = vkDestroySampler
}

extension VkEventCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkEvent.Pointee
    public static let createFunction: CreateFunction = vkCreateEvent
    public static let deleteFunction: DeleteFunction = vkDestroyEvent
}

extension VkQueryPoolCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkQueryPool.Pointee
    public static let createFunction: CreateFunction = vkCreateQueryPool
    public static let deleteFunction: DeleteFunction = vkDestroyQueryPool
}

extension VkBufferCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkBuffer.Pointee
    public static let createFunction: CreateFunction = vkCreateBuffer
    public static let deleteFunction: DeleteFunction = vkDestroyBuffer
}

extension VkBufferViewCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkBufferView.Pointee
    public static let createFunction: CreateFunction = vkCreateBufferView
    public static let deleteFunction: DeleteFunction = vkDestroyBufferView
}

extension VkImageCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkImage.Pointee
    public static let createFunction: CreateFunction = vkCreateImage
    public static let deleteFunction: DeleteFunction = vkDestroyImage
}

extension VkDescriptorSetLayoutCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkDescriptorSetLayout.Pointee
    public static let createFunction: CreateFunction = vkCreateDescriptorSetLayout
    public static let deleteFunction: DeleteFunction = vkDestroyDescriptorSetLayout
}

extension VkDescriptorPoolCreateInfo: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkDescriptorPool.Pointee
    public static let createFunction: CreateFunction = vkCreateDescriptorPool
    public static let deleteFunction: DeleteFunction = vkDestroyDescriptorPool
}

extension VkRenderPassCreateInfo2: EntityInfo {
    public typealias Parent = VkDevice.Pointee
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction: CreateFunction = vkCreateRenderPass2
    public static let deleteFunction: DeleteFunction = vkDestroyRenderPass
}
