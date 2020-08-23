//
//  DeviceEntityInfo.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2020.
//

public protocol DeviceEntityInfo: EntityInfo {
    typealias Parent = VkDevice.Pointee
}

extension VkShaderModuleCreateInfo: DeviceEntityInfo {
    public typealias Result = VkShaderModule.Pointee
    public static let createFunction: CreateFunction = vkCreateShaderModule
    public static let deleteFunction: DeleteFunction = vkDestroyShaderModule
}

extension VkCommandPoolCreateInfo: DeviceEntityInfo {
    public typealias Result = VkCommandPool.Pointee
    public static let createFunction: CreateFunction = vkCreateCommandPool
    public static let deleteFunction: DeleteFunction = vkDestroyCommandPool
}

extension VkFenceCreateInfo: DeviceEntityInfo {
    public typealias Result = VkFence.Pointee
    public static let createFunction: CreateFunction = vkCreateFence
    public static let deleteFunction: DeleteFunction = vkDestroyFence
}

extension VkSwapchainCreateInfoKHR: DeviceEntityInfo {
    public typealias Result = VkSwapchainKHR.Pointee
    public static let createFunction: CreateFunction = vkCreateSwapchainKHR
    public static let deleteFunction: DeleteFunction = vkDestroySwapchainKHR
}

extension VkImageViewCreateInfo: DeviceEntityInfo {
    public typealias Result = VkImageView.Pointee
    public static let createFunction: CreateFunction = vkCreateImageView
    public static let deleteFunction: DeleteFunction = vkDestroyImageView
}

extension VkPipelineLayoutCreateInfo: DeviceEntityInfo {
    public typealias Result = VkPipelineLayout.Pointee
    public static let createFunction: CreateFunction = vkCreatePipelineLayout
    public static let deleteFunction: DeleteFunction = vkDestroyPipelineLayout
}

extension VkRenderPassCreateInfo: DeviceEntityInfo {
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction: CreateFunction = vkCreateRenderPass
    public static let deleteFunction: DeleteFunction = vkDestroyRenderPass
}

extension VkFramebufferCreateInfo: DeviceEntityInfo {
    public typealias Result = VkFramebuffer.Pointee
    public static let createFunction: CreateFunction = vkCreateFramebuffer
    public static let deleteFunction: DeleteFunction = vkDestroyFramebuffer
}

extension VkSemaphoreCreateInfo: DeviceEntityInfo {
    public typealias Result = VkSemaphore.Pointee
    public static let createFunction: CreateFunction = vkCreateSemaphore
    public static let deleteFunction: DeleteFunction = vkDestroySemaphore
}

extension VkSamplerCreateInfo: DeviceEntityInfo {
    public typealias Result = VkSampler.Pointee
    public static let createFunction: CreateFunction = vkCreateSampler
    public static let deleteFunction: DeleteFunction = vkDestroySampler
}

extension VkEventCreateInfo: DeviceEntityInfo {
    public typealias Result = VkEvent.Pointee
    public static let createFunction: CreateFunction = vkCreateEvent
    public static let deleteFunction: DeleteFunction = vkDestroyEvent
}

extension VkQueryPoolCreateInfo: DeviceEntityInfo {
    public typealias Result = VkQueryPool.Pointee
    public static let createFunction: CreateFunction = vkCreateQueryPool
    public static let deleteFunction: DeleteFunction = vkDestroyQueryPool
}

extension VkBufferCreateInfo: DeviceEntityInfo {
    public typealias Result = VkBuffer.Pointee
    public static let createFunction: CreateFunction = vkCreateBuffer
    public static let deleteFunction: DeleteFunction = vkDestroyBuffer
}

extension VkBufferViewCreateInfo: DeviceEntityInfo {
    public typealias Result = VkBufferView.Pointee
    public static let createFunction: CreateFunction = vkCreateBufferView
    public static let deleteFunction: DeleteFunction = vkDestroyBufferView
}

extension VkImageCreateInfo: DeviceEntityInfo {
    public typealias Result = VkImage.Pointee
    public static let createFunction: CreateFunction = vkCreateImage
    public static let deleteFunction: DeleteFunction = vkDestroyImage
}

extension VkDescriptorSetLayoutCreateInfo: DeviceEntityInfo {
    public typealias Result = VkDescriptorSetLayout.Pointee
    public static let createFunction: CreateFunction = vkCreateDescriptorSetLayout
    public static let deleteFunction: DeleteFunction = vkDestroyDescriptorSetLayout
}

extension VkDescriptorPoolCreateInfo: DeviceEntityInfo {
    public typealias Result = VkDescriptorPool.Pointee
    public static let createFunction: CreateFunction = vkCreateDescriptorPool
    public static let deleteFunction: DeleteFunction = vkDestroyDescriptorPool
}

extension VkRenderPassCreateInfo2: DeviceEntityInfo {
    public typealias Result = VkRenderPass.Pointee
    public static let createFunction: CreateFunction = vkCreateRenderPass2
    public static let deleteFunction: DeleteFunction = vkDestroyRenderPass
}
