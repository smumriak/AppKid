//
//  EntityInfo.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2020.
//

import CVulkan

public typealias AllocationCallbacks = UnsafePointer<VkAllocationCallbacks>

public protocol EntityInfo<Parent, Result>: VulkanChainableStructure {
    associatedtype Parent: EntityFactory & VkEntity
    associatedtype Result: VkEntity

    typealias ParentPointer = UnsafeMutablePointer<Parent>
    typealias ResultPoitner = UnsafeMutablePointer<Result>
    typealias PointerToSelf = UnsafePointer<Self>

    associatedtype CreateFunction
    associatedtype DeleteFunction
}

public protocol SimpleEntityInfo<Parent, Result>: EntityInfo where CreateFunction == ConcreteCreateFunction, DeleteFunction == ConcreteDeleteFunction {
    typealias ConcreteCreateFunction = (_ parent: ParentPointer?,
                                        _ pCreateInfo: PointerToSelf?,
                                        _ pAllocator: AllocationCallbacks?,
                                        _ pResult: UnsafeMutablePointer<ResultPoitner?>?) -> (VkResult)
    static var createFunction: CreateFunction { get }

    typealias ConcreteDeleteFunction = (_ parent: ParentPointer?,
                                        _ result: ResultPoitner?,
                                        _ pAllocator: AllocationCallbacks?) -> ()
    static var deleteFunction: DeleteFunction { get }
}

public protocol InstanceEntityInfo<Parent, Result>: EntityInfo where Parent == VkInstance.Pointee {}
public typealias SimpleInstanceEntityInfo = SimpleEntityInfo & InstanceEntityInfo

public protocol PhysicalDeviceEntityInfo<Parent, Result>: EntityInfo where Parent == VkPhysicalDevice.Pointee {}
public typealias SimplePhysicalDeviceEntityInfo = SimpleEntityInfo & PhysicalDeviceEntityInfo

public protocol DeviceEntityInfo<Parent, Result>: EntityInfo where Parent == VkDevice.Pointee {}
public typealias SimpleDeviceEntityInfo = SimpleEntityInfo & DeviceEntityInfo

public protocol PipelineEntityInfo<Parent, Result>: DeviceEntityInfo where Result == VkPipeline.Pointee, CreateFunction == ConcreteCreateFunction, DeleteFunction == ConcreteDeleteFunction {
    typealias ConcreteCreateFunction = (_ device: VkDevice?,
                                        _ pipelineCache: VkPipelineCache?,
                                        _ createInfoCount: CUnsignedInt,
                                        _ pCreateInfos: PointerToSelf?,
                                        _ pAllocator: AllocationCallbacks?,
                                        _ pPipelines: UnsafeMutablePointer<ResultPoitner?>?) -> (VkResult)
    static var createFunction: CreateFunction { get }

    typealias ConcreteDeleteFunction = (_ device: VkDevice?,
                                        _ pipeline: VkPipeline?,
                                        _ pAllocator: AllocationCallbacks?) -> ()
    static var deleteFunction: DeleteFunction { get }
}

#if os(Linux)
    extension VkXlibSurfaceCreateInfoKHR: SimpleInstanceEntityInfo {
        public typealias Result = VkSurfaceKHR.Pointee
        public static let createFunction = vkCreateXlibSurfaceKHR
        public static let deleteFunction = vkDestroySurfaceKHR
    }

#elseif os(macOS) || os(iOS)
    // extension VkMetalSurfaceCreateInfoEXT: SimpleInstanceEntityInfo {
    //     public typealias Result = VkSurfaceKHR.Pointee
    //     public static let createFunction  = vkCreateMetalSurfaceEXT
    //     public static let deleteFunction  = vkDestroySurfaceKHR
    // }

    #if os(macOS)
        extension VkMacOSSurfaceCreateInfoMVK: SimpleInstanceEntityInfo {
            public typealias Result = VkSurfaceKHR.Pointee
            public static let createFunction = vkCreateMacOSSurfaceMVK
            public static let deleteFunction = vkDestroySurfaceKHR
        }

    #elseif os(iOS)
        extension VkIOSSurfaceCreateInfoMVK: SimpleInstanceEntityInfo {
            public typealias Result = VkSurfaceKHR.Pointee
            public static let createFunction = vkCreateIOSSurfaceMVK
            public static let deleteFunction = vkDestroySurfaceKHR
        }
    #endif
#endif

extension VkDeviceCreateInfo: SimplePhysicalDeviceEntityInfo {
    public typealias Result = VkDevice.Pointee
    public static let createFunction: CreateFunction = vkCreateDevice
    public static let deleteFunction: DeleteFunction = { physicalDevice, device, allocator in
        vkDestroyDevice(device, allocator)
    }
}

extension VkShaderModuleCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkShaderModule.Pointee
    public static let createFunction = vkCreateShaderModule
    public static let deleteFunction = vkDestroyShaderModule
}

extension VkCommandPoolCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkCommandPool.Pointee
    public static let createFunction = vkCreateCommandPool
    public static let deleteFunction = vkDestroyCommandPool
}

extension VkFenceCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkFence.Pointee
    public static let createFunction = vkCreateFence
    public static let deleteFunction = vkDestroyFence
}

extension VkSwapchainCreateInfoKHR: SimpleDeviceEntityInfo {
    public typealias Result = VkSwapchainKHR.Pointee
    public static let createFunction = vkCreateSwapchainKHR
    public static let deleteFunction = vkDestroySwapchainKHR
}

extension VkImageViewCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkImageView.Pointee
    public static let createFunction = vkCreateImageView
    public static let deleteFunction = vkDestroyImageView
}

extension VkPipelineLayoutCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkPipelineLayout.Pointee
    public static let createFunction = vkCreatePipelineLayout
    public static let deleteFunction = vkDestroyPipelineLayout
}

extension VkRenderPassCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction = vkCreateRenderPass
    public static let deleteFunction = vkDestroyRenderPass
}

extension VkFramebufferCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkFramebuffer.Pointee
    public static let createFunction = vkCreateFramebuffer
    public static let deleteFunction = vkDestroyFramebuffer
}

extension VkSemaphoreCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkSemaphore.Pointee
    public static let createFunction = vkCreateSemaphore
    public static let deleteFunction = vkDestroySemaphore
}

extension VkSamplerCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkSampler.Pointee
    public static let createFunction = vkCreateSampler
    public static let deleteFunction = vkDestroySampler
}

extension VkEventCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkEvent.Pointee
    public static let createFunction = vkCreateEvent
    public static let deleteFunction = vkDestroyEvent
}

extension VkQueryPoolCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkQueryPool.Pointee
    public static let createFunction = vkCreateQueryPool
    public static let deleteFunction = vkDestroyQueryPool
}

extension VkBufferCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkBuffer.Pointee
    public static let createFunction = vkCreateBuffer
    public static let deleteFunction = vkDestroyBuffer
}

extension VkBufferViewCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkBufferView.Pointee
    public static let createFunction = vkCreateBufferView
    public static let deleteFunction = vkDestroyBufferView
}

extension VkImageCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkImage.Pointee
    public static let createFunction = vkCreateImage
    public static let deleteFunction = vkDestroyImage
}

extension VkDescriptorSetLayoutCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkDescriptorSetLayout.Pointee
    public static let createFunction = vkCreateDescriptorSetLayout
    public static let deleteFunction = vkDestroyDescriptorSetLayout
}

extension VkDescriptorPoolCreateInfo: SimpleDeviceEntityInfo {
    public typealias Result = VkDescriptorPool.Pointee
    public static let createFunction = vkCreateDescriptorPool
    public static let deleteFunction = vkDestroyDescriptorPool
}

extension VkRenderPassCreateInfo2: SimpleDeviceEntityInfo {
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction = vkCreateRenderPass2
    public static let deleteFunction = vkDestroyRenderPass
}

extension VkGraphicsPipelineCreateInfo: PipelineEntityInfo {
    public static let createFunction = vkCreateGraphicsPipelines
    public static let deleteFunction = vkDestroyPipeline
}

extension VkComputePipelineCreateInfo: PipelineEntityInfo {
    public static let createFunction = vkCreateComputePipelines
    public static let deleteFunction = vkDestroyPipeline
}
