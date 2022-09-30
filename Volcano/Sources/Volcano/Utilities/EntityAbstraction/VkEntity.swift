//
//  VkEntity.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import CVulkan

@_marker
public protocol VkEntity {}

@_marker
public protocol VkDeviceEntity: VkEntity {}

extension VkInstance_T: VkEntity {}
extension VkPhysicalDevice_T: VkEntity {}
extension VkSurfaceKHR_T: VkEntity {}
extension VkDevice_T: VkEntity {}
extension VkShaderModule_T: VkDeviceEntity {}
extension VkCommandPool_T: VkDeviceEntity {}
extension VkCommandBuffer_T: VkDeviceEntity {}
extension VkFence_T: VkDeviceEntity {}
extension VkSwapchainKHR_T: VkDeviceEntity {}
extension VkImageView_T: VkDeviceEntity {}
extension VkPipelineLayout_T: VkDeviceEntity {}
extension VkPipeline_T: VkDeviceEntity {}
extension VkRenderPass_T: VkDeviceEntity {}
extension VkFramebuffer_T: VkDeviceEntity {}
extension VkSemaphore_T: VkDeviceEntity {}
extension VkSampler_T: VkDeviceEntity {}
extension VkEvent_T: VkDeviceEntity {}
extension VkQueryPool_T: VkDeviceEntity {}
extension VkBuffer_T: VkDeviceEntity {}
extension VkBufferView_T: VkDeviceEntity {}
extension VkImage_T: VkDeviceEntity {}
extension VkDescriptorSetLayout_T: VkDeviceEntity {}
extension VkDescriptorPool_T: VkDeviceEntity {}
extension VkDeviceMemory_T: VkDeviceEntity {}