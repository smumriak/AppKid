//
//  DeviceEntityInfo.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2020.
//

import Foundation
import TinyFoundation
import CVulkan

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
