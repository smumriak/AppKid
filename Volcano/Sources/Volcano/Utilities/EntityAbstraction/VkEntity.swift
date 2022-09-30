//
//  VkEntity.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import CVulkan

@_marker
public protocol VkEntity {}

extension VkInstance_T: VkEntity {}
extension VkPhysicalDevice_T: VkEntity {}
extension VkSurfaceKHR_T: VkEntity {}
extension VkDevice_T: VkEntity {}
extension VkShaderModule_T: VkEntity {}
extension VkCommandPool_T: VkEntity {}
extension VkFence_T: VkEntity {}
extension VkSwapchainKHR_T: VkEntity {}
extension VkImageView_T: VkEntity {}
extension VkPipelineLayout_T: VkEntity {}
extension VkPipeline_T: VkEntity {}
extension VkRenderPass_T: VkEntity {}
extension VkFramebuffer_T: VkEntity {}
extension VkSemaphore_T: VkEntity {}
extension VkSampler_T: VkEntity {}
extension VkEvent_T: VkEntity {}
extension VkQueryPool_T: VkEntity {}
extension VkBuffer_T: VkEntity {}
extension VkBufferView_T: VkEntity {}
extension VkImage_T: VkEntity {}
extension VkDescriptorSetLayout_T: VkEntity {}
extension VkDescriptorPool_T: VkEntity {}
