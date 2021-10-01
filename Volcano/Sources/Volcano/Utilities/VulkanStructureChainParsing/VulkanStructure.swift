//
//  VulkanStructure.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2021.
//

import TinyFoundation
import CVulkan

public protocol VulkanBaseStructure: PublicInitializable {
    var sType: VkStructureType { get set }
}

extension VkBaseInStructure: VulkanBaseStructure {}
extension VkBaseOutStructure: VulkanBaseStructure {}

public protocol VulkanStructure: VulkanBaseStructure {
    static var type: VkStructureType { get }
}

public protocol VulkanChainableStructure: VulkanStructure {
    var pNext: UnsafeRawPointer! { get set }
}

public extension VulkanChainableStructure {
    mutating func withUnsafeRawPointer<R>(_ body: (UnsafeRawPointer) throws -> (R)) rethrows -> R {
        try withUnsafePointer(to: &self) {
            try body(UnsafeRawPointer($0))
        }
    }
}

public protocol VulkanInStructure: VulkanChainableStructure {
    var pNext: UnsafeRawPointer! { get set }
}

public protocol VulkanOutStructure: VulkanChainableStructure {
    var pNext: UnsafeMutableRawPointer! { get set }
}

public extension VulkanOutStructure {
    var pNext: UnsafeRawPointer! {
        get {
            return UnsafeRawPointer(pNext)
        }
        set {
            pNext = UnsafeMutableRawPointer(mutating: newValue)
        }
    }
}

public extension VulkanStructure {
    static func new() -> Self {
        var result = Self()
        result.sType = Self.type
        return result
    }
}

internal extension UnsafePointer where Pointee: VulkanOutStructure {
    var vulkanIn: UnsafePointer<VkBaseInStructure> {
        return UnsafeRawPointer(self).assumingMemoryBound(to: VkBaseInStructure.self)
    }
}

internal extension UnsafeMutablePointer where Pointee: VulkanOutStructure {
    var vulkanIn: UnsafePointer<VkBaseInStructure> {
        return UnsafeRawPointer(self).assumingMemoryBound(to: VkBaseInStructure.self)
    }

    var vulkanOut: UnsafeMutablePointer<VkBaseInStructure> {
        return UnsafeMutableRawPointer(self).assumingMemoryBound(to: VkBaseInStructure.self)
    }
}

extension VkApplicationInfo: VulkanInStructure {
    public static let type: VkStructureType = .applicationInfo
}

extension VkInstanceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .instanceCreateInfo
}

extension VkDeviceQueueCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceQueueCreateInfo
}

extension VkDeviceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceCreateInfo
}

extension VkSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .submitInfo
}

extension VkMemoryAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .memoryAllocateInfo
}

extension VkMappedMemoryRange: VulkanInStructure {
    public static let type: VkStructureType = .mappedMemoryRange
}

extension VkBindSparseInfo: VulkanInStructure {
    public static let type: VkStructureType = .bindSparseInfo
}

extension VkFenceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .fenceCreateInfo
}

extension VkSemaphoreCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .semaphoreCreateInfo
}

extension VkEventCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .eventCreateInfo
}

extension VkQueryPoolCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .queryPoolCreateInfo
}

extension VkBufferCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .bufferCreateInfo
}

extension VkBufferViewCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .bufferViewCreateInfo
}

extension VkImageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .imageCreateInfo
}

extension VkImageViewCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .imageViewCreateInfo
}

extension VkShaderModuleCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .shaderModuleCreateInfo
}

extension VkPipelineCacheCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineCacheCreateInfo
}

extension VkPipelineShaderStageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineShaderStageCreateInfo
}

extension VkPipelineVertexInputStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineVertexInputStateCreateInfo
}

extension VkPipelineInputAssemblyStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineInputAssemblyStateCreateInfo
}

extension VkPipelineTessellationStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineTessellationStateCreateInfo
}

extension VkPipelineViewportStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineViewportStateCreateInfo
}

extension VkPipelineRasterizationStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRasterizationStateCreateInfo
}

extension VkPipelineMultisampleStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineMultisampleStateCreateInfo
}

extension VkPipelineDepthStencilStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineDepthStencilStateCreateInfo
}

extension VkPipelineColorBlendStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineColorBlendStateCreateInfo
}

extension VkPipelineDynamicStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineDynamicStateCreateInfo
}

extension VkGraphicsPipelineCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .graphicsPipelineCreateInfo
}

extension VkComputePipelineCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .computePipelineCreateInfo
}

extension VkPipelineLayoutCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineLayoutCreateInfo
}

extension VkSamplerCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .samplerCreateInfo
}

extension VkDescriptorSetLayoutCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .descriptorSetLayoutCreateInfo
}

extension VkDescriptorPoolCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .descriptorPoolCreateInfo
}

extension VkDescriptorSetAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .descriptorSetAllocateInfo
}

extension VkWriteDescriptorSet: VulkanInStructure {
    public static let type: VkStructureType = .writeDescriptorSet
}

extension VkCopyDescriptorSet: VulkanInStructure {
    public static let type: VkStructureType = .copyDescriptorSet
}

extension VkFramebufferCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .framebufferCreateInfo
}

extension VkRenderPassCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .renderPassCreateInfo
}

extension VkCommandPoolCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .commandPoolCreateInfo
}

extension VkCommandBufferAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .commandBufferAllocateInfo
}

extension VkCommandBufferInheritanceInfo: VulkanInStructure {
    public static let type: VkStructureType = .commandBufferInheritanceInfo
}

extension VkCommandBufferBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .commandBufferBeginInfo
}

extension VkRenderPassBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .renderPassBeginInfo
}

extension VkBufferMemoryBarrier: VulkanInStructure {
    public static let type: VkStructureType = .bufferMemoryBarrier
}

extension VkImageMemoryBarrier: VulkanInStructure {
    public static let type: VkStructureType = .imageMemoryBarrier
}

extension VkMemoryBarrier: VulkanInStructure {
    public static let type: VkStructureType = .memoryBarrier
}

extension VkPhysicalDeviceSubgroupProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSubgroupProperties
}

extension VkBindBufferMemoryInfo: VulkanInStructure {
    public static let type: VkStructureType = .bindBufferMemoryInfo
}

extension VkBindImageMemoryInfo: VulkanInStructure {
    public static let type: VkStructureType = .bindImageMemoryInfo
}

extension VkPhysicalDevice16BitStorageFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevice16BitStorageFeatures
}

extension VkMemoryDedicatedRequirements: VulkanOutStructure {
    public static let type: VkStructureType = .memoryDedicatedRequirements
}

extension VkMemoryDedicatedAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .memoryDedicatedAllocateInfo
}

extension VkMemoryAllocateFlagsInfo: VulkanInStructure {
    public static let type: VkStructureType = .memoryAllocateFlagsInfo
}

extension VkDeviceGroupRenderPassBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceGroupRenderPassBeginInfo
}

extension VkDeviceGroupCommandBufferBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceGroupCommandBufferBeginInfo
}

extension VkDeviceGroupSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceGroupSubmitInfo
}

extension VkDeviceGroupBindSparseInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceGroupBindSparseInfo
}

extension VkBindBufferMemoryDeviceGroupInfo: VulkanInStructure {
    public static let type: VkStructureType = .bindBufferMemoryDeviceGroupInfo
}

extension VkBindImageMemoryDeviceGroupInfo: VulkanInStructure {
    public static let type: VkStructureType = .bindImageMemoryDeviceGroupInfo
}

extension VkPhysicalDeviceGroupProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceGroupProperties
}

extension VkDeviceGroupDeviceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceGroupDeviceCreateInfo
}

extension VkBufferMemoryRequirementsInfo2: VulkanInStructure {
    public static let type: VkStructureType = .bufferMemoryRequirementsInfo2
}

extension VkImageMemoryRequirementsInfo2: VulkanInStructure {
    public static let type: VkStructureType = .imageMemoryRequirementsInfo2
}

extension VkImageSparseMemoryRequirementsInfo2: VulkanInStructure {
    public static let type: VkStructureType = .imageSparseMemoryRequirementsInfo2
}

extension VkMemoryRequirements2: VulkanOutStructure {
    public static let type: VkStructureType = .memoryRequirements2
}

extension VkSparseImageMemoryRequirements2: VulkanOutStructure {
    public static let type: VkStructureType = .sparseImageMemoryRequirements2
}

extension VkPhysicalDeviceFeatures2: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFeatures2
}

extension VkPhysicalDeviceProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceProperties2
}

extension VkFormatProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .formatProperties2
}

extension VkImageFormatProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .imageFormatProperties2
}

extension VkPhysicalDeviceImageFormatInfo2: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceImageFormatInfo2
}

extension VkQueueFamilyProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .queueFamilyProperties2
}

extension VkPhysicalDeviceMemoryProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMemoryProperties2
}

extension VkSparseImageFormatProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .sparseImageFormatProperties2
}

extension VkPhysicalDeviceSparseImageFormatInfo2: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceSparseImageFormatInfo2
}

extension VkPhysicalDevicePointClippingProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePointClippingProperties
}

extension VkRenderPassInputAttachmentAspectCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .renderPassInputAttachmentAspectCreateInfo
}

extension VkImageViewUsageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .imageViewUsageCreateInfo
}

extension VkPipelineTessellationDomainOriginStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .pipelineTessellationDomainOriginStateCreateInfo
}

extension VkRenderPassMultiviewCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .renderPassMultiviewCreateInfo
}

extension VkPhysicalDeviceMultiviewFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMultiviewFeatures
}

extension VkPhysicalDeviceMultiviewProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMultiviewProperties
}

extension VkPhysicalDeviceVariablePointersFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVariablePointersFeatures
}

extension VkProtectedSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .protectedSubmitInfo
}

extension VkPhysicalDeviceProtectedMemoryFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceProtectedMemoryFeatures
}

extension VkPhysicalDeviceProtectedMemoryProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceProtectedMemoryProperties
}

extension VkDeviceQueueInfo2: VulkanInStructure {
    public static let type: VkStructureType = .deviceQueueInfo2
}

extension VkSamplerYcbcrConversionCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .samplerYcbcrConversionCreateInfo
}

extension VkSamplerYcbcrConversionInfo: VulkanInStructure {
    public static let type: VkStructureType = .samplerYcbcrConversionInfo
}

extension VkBindImagePlaneMemoryInfo: VulkanInStructure {
    public static let type: VkStructureType = .bindImagePlaneMemoryInfo
}

extension VkImagePlaneMemoryRequirementsInfo: VulkanInStructure {
    public static let type: VkStructureType = .imagePlaneMemoryRequirementsInfo
}

extension VkPhysicalDeviceSamplerYcbcrConversionFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSamplerYcbcrConversionFeatures
}

extension VkSamplerYcbcrConversionImageFormatProperties: VulkanOutStructure {
    public static let type: VkStructureType = .samplerYcbcrConversionImageFormatProperties
}

extension VkDescriptorUpdateTemplateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .descriptorUpdateTemplateCreateInfo
}

extension VkPhysicalDeviceExternalImageFormatInfo: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceExternalImageFormatInfo
}

extension VkExternalImageFormatProperties: VulkanOutStructure {
    public static let type: VkStructureType = .externalImageFormatProperties
}

extension VkPhysicalDeviceExternalBufferInfo: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceExternalBufferInfo
}

extension VkExternalBufferProperties: VulkanOutStructure {
    public static let type: VkStructureType = .externalBufferProperties
}

extension VkExternalMemoryBufferCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .externalMemoryBufferCreateInfo
}

extension VkExternalMemoryImageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .externalMemoryImageCreateInfo
}

extension VkExportMemoryAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .exportMemoryAllocateInfo
}

extension VkPhysicalDeviceExternalFenceInfo: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceExternalFenceInfo
}

extension VkExternalFenceProperties: VulkanOutStructure {
    public static let type: VkStructureType = .externalFenceProperties
}

extension VkExportFenceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .exportFenceCreateInfo
}

extension VkExportSemaphoreCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .exportSemaphoreCreateInfo
}

extension VkPhysicalDeviceExternalSemaphoreInfo: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceExternalSemaphoreInfo
}

extension VkExternalSemaphoreProperties: VulkanOutStructure {
    public static let type: VkStructureType = .externalSemaphoreProperties
}

extension VkPhysicalDeviceMaintenance3Properties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMaintenance3Properties
}

extension VkDescriptorSetLayoutSupport: VulkanOutStructure {
    public static let type: VkStructureType = .descriptorSetLayoutSupport
}

extension VkPhysicalDeviceShaderDrawParametersFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderDrawParametersFeatures
}

extension VkPhysicalDeviceVulkan11Features: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVulkan11Features
}

extension VkPhysicalDeviceVulkan11Properties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVulkan11Properties
}

extension VkPhysicalDeviceVulkan12Features: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVulkan12Features
}

extension VkPhysicalDeviceVulkan12Properties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVulkan12Properties
}

extension VkImageFormatListCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .imageFormatListCreateInfo
}

extension VkAttachmentDescription2: VulkanInStructure {
    public static let type: VkStructureType = .attachmentDescription2
}

extension VkAttachmentReference2: VulkanInStructure {
    public static let type: VkStructureType = .attachmentReference2
}

extension VkSubpassDescription2: VulkanInStructure {
    public static let type: VkStructureType = .subpassDescription2
}

extension VkSubpassDependency2: VulkanInStructure {
    public static let type: VkStructureType = .subpassDependency2
}

extension VkRenderPassCreateInfo2: VulkanInStructure {
    public static let type: VkStructureType = .renderPassCreateInfo2
}

extension VkSubpassBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .subpassBeginInfo
}

extension VkSubpassEndInfo: VulkanInStructure {
    public static let type: VkStructureType = .subpassEndInfo
}

extension VkPhysicalDevice8BitStorageFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevice8BitStorageFeatures
}

extension VkPhysicalDeviceDriverProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDriverProperties
}

extension VkPhysicalDeviceShaderAtomicInt64Features: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderAtomicInt64Features
}

extension VkPhysicalDeviceShaderFloat16Int8Features: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderFloat16Int8Features
}

extension VkPhysicalDeviceFloatControlsProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFloatControlsProperties
}

extension VkDescriptorSetLayoutBindingFlagsCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .descriptorSetLayoutBindingFlagsCreateInfo
}

extension VkPhysicalDeviceDescriptorIndexingFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDescriptorIndexingFeatures
}

extension VkPhysicalDeviceDescriptorIndexingProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDescriptorIndexingProperties
}

extension VkDescriptorSetVariableDescriptorCountAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .descriptorSetVariableDescriptorCountAllocateInfo
}

extension VkDescriptorSetVariableDescriptorCountLayoutSupport: VulkanOutStructure {
    public static let type: VkStructureType = .descriptorSetVariableDescriptorCountLayoutSupport
}

extension VkPhysicalDeviceDepthStencilResolveProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDepthStencilResolveProperties
}

extension VkSubpassDescriptionDepthStencilResolve: VulkanInStructure {
    public static let type: VkStructureType = .subpassDescriptionDepthStencilResolve
}

extension VkPhysicalDeviceScalarBlockLayoutFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceScalarBlockLayoutFeatures
}

extension VkImageStencilUsageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .imageStencilUsageCreateInfo
}

extension VkPhysicalDeviceSamplerFilterMinmaxProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSamplerFilterMinmaxProperties
}

extension VkSamplerReductionModeCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .samplerReductionModeCreateInfo
}

extension VkPhysicalDeviceVulkanMemoryModelFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVulkanMemoryModelFeatures
}

extension VkPhysicalDeviceImagelessFramebufferFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceImagelessFramebufferFeatures
}

extension VkFramebufferAttachmentsCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .framebufferAttachmentsCreateInfo
}

extension VkFramebufferAttachmentImageInfo: VulkanInStructure {
    public static let type: VkStructureType = .framebufferAttachmentImageInfo
}

extension VkRenderPassAttachmentBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .renderPassAttachmentBeginInfo
}

extension VkPhysicalDeviceUniformBufferStandardLayoutFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceUniformBufferStandardLayoutFeatures
}

extension VkPhysicalDeviceShaderSubgroupExtendedTypesFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderSubgroupExtendedTypesFeatures
}

extension VkPhysicalDeviceSeparateDepthStencilLayoutsFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSeparateDepthStencilLayoutsFeatures
}

extension VkAttachmentReferenceStencilLayout: VulkanOutStructure {
    public static let type: VkStructureType = .attachmentReferenceStencilLayout
}

extension VkAttachmentDescriptionStencilLayout: VulkanOutStructure {
    public static let type: VkStructureType = .attachmentDescriptionStencilLayout
}

extension VkPhysicalDeviceHostQueryResetFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceHostQueryResetFeatures
}

extension VkPhysicalDeviceTimelineSemaphoreFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceTimelineSemaphoreFeatures
}

extension VkPhysicalDeviceTimelineSemaphoreProperties: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceTimelineSemaphoreProperties
}

extension VkSemaphoreTypeCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .semaphoreTypeCreateInfo
}

extension VkTimelineSemaphoreSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .timelineSemaphoreSubmitInfo
}

extension VkSemaphoreWaitInfo: VulkanInStructure {
    public static let type: VkStructureType = .semaphoreWaitInfo
}

extension VkSemaphoreSignalInfo: VulkanInStructure {
    public static let type: VkStructureType = .semaphoreSignalInfo
}

extension VkPhysicalDeviceBufferDeviceAddressFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceBufferDeviceAddressFeatures
}

extension VkBufferDeviceAddressInfo: VulkanInStructure {
    public static let type: VkStructureType = .bufferDeviceAddressInfo
}

extension VkBufferOpaqueCaptureAddressCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .bufferOpaqueCaptureAddressCreateInfo
}

extension VkMemoryOpaqueCaptureAddressAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .memoryOpaqueCaptureAddressAllocateInfo
}

extension VkDeviceMemoryOpaqueCaptureAddressInfo: VulkanInStructure {
    public static let type: VkStructureType = .deviceMemoryOpaqueCaptureAddressInfo
}

extension VkSwapchainCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .swapchainCreateInfoKhr
}

extension VkPresentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .presentInfoKhr
}

extension VkDeviceGroupPresentCapabilitiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .deviceGroupPresentCapabilitiesKhr
}

extension VkImageSwapchainCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .imageSwapchainCreateInfoKhr
}

extension VkBindImageMemorySwapchainInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .bindImageMemorySwapchainInfoKhr
}

extension VkAcquireNextImageInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .acquireNextImageInfoKhr
}

extension VkDeviceGroupPresentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .deviceGroupPresentInfoKhr
}

extension VkDeviceGroupSwapchainCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .deviceGroupSwapchainCreateInfoKhr
}

extension VkDisplayModeCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .displayModeCreateInfoKhr
}

extension VkDisplaySurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .displaySurfaceCreateInfoKhr
}

extension VkDisplayPresentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .displayPresentInfoKhr
}

extension VkXlibSurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .xlibSurfaceCreateInfoKhr
}

#if canImport(CXcb)
    extension VkXcbSurfaceCreateInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .xcbSurfaceCreateInfoKhr
    }
#endif

#if canImport(CWayland)
    extension VkWaylandSurfaceCreateInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .waylandSurfaceCreateInfoKhr
    }
#endif

#if os(Android)
    extension VkAndroidSurfaceCreateInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .androidSurfaceCreateInfoKhr
    }
#endif

#if os(Windows)
    extension VkWin32SurfaceCreateInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .win32SurfaceCreateInfoKhr
    }
#endif

extension VkDebugReportCallbackCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugReportCallbackCreateInfoExt
}

extension VkPipelineRasterizationStateRasterizationOrderAMD: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRasterizationStateRasterizationOrderAmd
}

extension VkDebugMarkerObjectNameInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugMarkerObjectNameInfoExt
}

extension VkDebugMarkerObjectTagInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugMarkerObjectTagInfoExt
}

extension VkDebugMarkerMarkerInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugMarkerMarkerInfoExt
}

extension VkDedicatedAllocationImageCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .dedicatedAllocationImageCreateInfoNv
}

extension VkDedicatedAllocationBufferCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .dedicatedAllocationBufferCreateInfoNv
}

extension VkDedicatedAllocationMemoryAllocateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .dedicatedAllocationMemoryAllocateInfoNv
}

extension VkPhysicalDeviceTransformFeedbackFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceTransformFeedbackFeaturesExt
}

extension VkPhysicalDeviceTransformFeedbackPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceTransformFeedbackPropertiesExt
}

extension VkPipelineRasterizationStateStreamCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRasterizationStateStreamCreateInfoExt
}

extension VkCuModuleCreateInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .cuModuleCreateInfoNvx
}

extension VkCuFunctionCreateInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .cuFunctionCreateInfoNvx
}

extension VkCuLaunchInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .cuLaunchInfoNvx
}

extension VkImageViewHandleInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .imageViewHandleInfoNvx
}

extension VkImageViewAddressPropertiesNVX: VulkanOutStructure {
    public static let type: VkStructureType = .imageViewAddressPropertiesNvx
}

extension VkTextureLODGatherFormatPropertiesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .textureLodGatherFormatPropertiesAmd
}

extension VkPhysicalDeviceCornerSampledImageFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceCornerSampledImageFeaturesNv
}

extension VkExternalMemoryImageCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .externalMemoryImageCreateInfoNv
}

extension VkExportMemoryAllocateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .exportMemoryAllocateInfoNv
}

#if os(Windows)
    extension VkImportMemoryWin32HandleInfoNV: VulkanOutStructure {
        public static let type: VkStructureType = .importMemoryWin32HandleInfoNv
    }

    extension VkExportMemoryWin32HandleInfoNV: VulkanOutStructure {
        public static let type: VkStructureType = .exportMemoryWin32HandleInfoNv
    }

    extension VkWin32KeyedMutexAcquireReleaseInfoNV: VulkanOutStructure {
        public static let type: VkStructureType = .win32KeyedMutexAcquireReleaseInfoNv
    }
#endif

extension VkValidationFlagsEXT: VulkanInStructure {
    public static let type: VkStructureType = .validationFlagsExt
}

extension VkPhysicalDeviceTextureCompressionASTCHDRFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceTextureCompressionAstcHdrFeaturesExt
}

extension VkPhysicalDeviceASTCDecodeFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceAstcDecodeFeaturesExt
}

#if os(Windows)
    extension VkImportMemoryWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .importMemoryWin32HandleInfoKhr
    }

    extension VkExportMemoryWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .exportMemoryWin32HandleInfoKhr
    }

    extension VkMemoryWin32HandlePropertiesKHR: VulkanOutStructure {
        public static let type: VkStructureType = .memoryWin32HandlePropertiesKhr
    }

    extension VkMemoryGetWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .memoryGetWin32HandleInfoKhr
    }
#endif

#if os(Linux)
    extension VkImportMemoryFdInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .importMemoryFdInfoKhr
    }

    extension VkMemoryFdPropertiesKHR: VulkanOutStructure {
        public static let type: VkStructureType = .memoryFdPropertiesKhr
    }

    extension VkMemoryGetFdInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .memoryGetFdInfoKhr
    }
#endif

#if os(Windows)
    extension VkWin32KeyedMutexAcquireReleaseInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .win32KeyedMutexAcquireReleaseInfoKhr
    }

    extension VkImportSemaphoreWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .importSemaphoreWin32HandleInfoKhr
    }

    extension VkExportSemaphoreWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .exportSemaphoreWin32HandleInfoKhr
    }

    extension VkD3D12FenceSubmitInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .d3D12FenceSubmitInfoKhr
    }

    extension VkSemaphoreGetWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .semaphoreGetWin32HandleInfoKhr
    }
#endif

#if os(Linux)
    extension VkImportSemaphoreFdInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .importSemaphoreFdInfoKhr
    }

    extension VkSemaphoreGetFdInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .semaphoreGetFdInfoKhr
    }
#endif

extension VkPhysicalDevicePushDescriptorPropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePushDescriptorPropertiesKhr
}

extension VkCommandBufferInheritanceConditionalRenderingInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .commandBufferInheritanceConditionalRenderingInfoExt
}

extension VkPhysicalDeviceConditionalRenderingFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceConditionalRenderingFeaturesExt
}

extension VkConditionalRenderingBeginInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .conditionalRenderingBeginInfoExt
}

extension VkPresentRegionsKHR: VulkanInStructure {
    public static let type: VkStructureType = .presentRegionsKhr
}

extension VkPipelineViewportWScalingStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineViewportWScalingStateCreateInfoNv
}

extension VkSurfaceCapabilities2EXT: VulkanOutStructure {
    public static let type: VkStructureType = .surfaceCapabilities2Ext
}

extension VkDisplayPowerInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .displayPowerInfoExt
}

extension VkDeviceEventInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .deviceEventInfoExt
}

extension VkDisplayEventInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .displayEventInfoExt
}

extension VkSwapchainCounterCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .swapchainCounterCreateInfoExt
}

extension VkPresentTimesInfoGOOGLE: VulkanInStructure {
    public static let type: VkStructureType = .presentTimesInfoGoogle
}

extension VkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMultiviewPerViewAttributesPropertiesNvx
}

extension VkPipelineViewportSwizzleStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineViewportSwizzleStateCreateInfoNv
}

extension VkPhysicalDeviceDiscardRectanglePropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDiscardRectanglePropertiesExt
}

extension VkPipelineDiscardRectangleStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineDiscardRectangleStateCreateInfoExt
}

extension VkPhysicalDeviceConservativeRasterizationPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceConservativeRasterizationPropertiesExt
}

extension VkPipelineRasterizationConservativeStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRasterizationConservativeStateCreateInfoExt
}

extension VkPhysicalDeviceDepthClipEnableFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDepthClipEnableFeaturesExt
}

extension VkPipelineRasterizationDepthClipStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRasterizationDepthClipStateCreateInfoExt
}

extension VkHdrMetadataEXT: VulkanInStructure {
    public static let type: VkStructureType = .hdrMetadataExt
}

extension VkSharedPresentSurfaceCapabilitiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .sharedPresentSurfaceCapabilitiesKhr
}

#if os(Windows)
    extension VkImportFenceWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .importFenceWin32HandleInfoKhr
    }

    extension VkExportFenceWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .exportFenceWin32HandleInfoKhr
    }

    extension VkFenceGetWin32HandleInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .fenceGetWin32HandleInfoKhr
    }
#endif

#if os(Linux)
    extension VkImportFenceFdInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .importFenceFdInfoKhr
    }

    extension VkFenceGetFdInfoKHR: VulkanInStructure {
        public static let type: VkStructureType = .fenceGetFdInfoKhr
    }
#endif

extension VkPhysicalDevicePerformanceQueryFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePerformanceQueryFeaturesKhr
}

extension VkPhysicalDevicePerformanceQueryPropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePerformanceQueryPropertiesKhr
}

extension VkQueryPoolPerformanceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .queryPoolPerformanceCreateInfoKhr
}

extension VkPerformanceQuerySubmitInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .performanceQuerySubmitInfoKhr
}

extension VkAcquireProfilingLockInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .acquireProfilingLockInfoKhr
}

extension VkPerformanceCounterKHR: VulkanOutStructure {
    public static let type: VkStructureType = .performanceCounterKhr
}

extension VkPerformanceCounterDescriptionKHR: VulkanOutStructure {
    public static let type: VkStructureType = .performanceCounterDescriptionKhr
}

extension VkPhysicalDeviceSurfaceInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceSurfaceInfo2Khr
}

extension VkSurfaceCapabilities2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .surfaceCapabilities2Khr
}

extension VkSurfaceFormat2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .surfaceFormat2Khr
}

extension VkDisplayProperties2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .displayProperties2Khr
}

extension VkDisplayPlaneProperties2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .displayPlaneProperties2Khr
}

extension VkDisplayModeProperties2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .displayModeProperties2Khr
}

extension VkDisplayPlaneInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .displayPlaneInfo2Khr
}

extension VkDisplayPlaneCapabilities2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .displayPlaneCapabilities2Khr
}

#if os(iOS)
    extension VkIosSurfaceCreateInfoMvk: VulkanInStructure {
        public static let type: VkStructureType = .iosSurfaceCreateInfoMvk
    }
#endif

#if os(macOS)
    extension VkMacosSurfaceCreateInfoMvk: VulkanInStructure {
        public static let type: VkStructureType = .macosSurfaceCreateInfoMvk
    }
#endif

extension VkDebugUtilsObjectNameInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugUtilsObjectNameInfoExt
}

extension VkDebugUtilsObjectTagInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugUtilsObjectTagInfoExt
}

extension VkDebugUtilsLabelEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugUtilsLabelExt
}

extension VkDebugUtilsMessengerCallbackDataEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugUtilsMessengerCallbackDataExt
}

extension VkDebugUtilsMessengerCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .debugUtilsMessengerCreateInfoExt
}

#if os(Android)
    extension VkAndroidHardwareBufferUsageAndroid: VulkanOutStructure {
        public static let type: VkStructureType = .androidHardwareBufferUsageAndroid
    }

    extension VkAndroidHardwareBufferPropertiesAndroid: VulkanOutStructure {
        public static let type: VkStructureType = .androidHardwareBufferPropertiesAndroid
    }

    extension VkAndroidHardwareBufferFormatPropertiesAndroid: VulkanOutStructure {
        public static let type: VkStructureType = .androidHardwareBufferFormatPropertiesAndroid
    }

    extension VkImportAndroidHardwareBufferInfoAndroid: VulkanInStructure {
        public static let type: VkStructureType = .importAndroidHardwareBufferInfoAndroid
    }

    extension VkMemoryGetAndroidHardwareBufferInfoAndroid: VulkanInStructure {
        public static let type: VkStructureType = .memoryGetAndroidHardwareBufferInfoAndroid
    }

    extension VkExternalFormatAndroid: VulkanOutStructure {
        public static let type: VkStructureType = .externalFormatAndroid
    }
#endif

extension VkPhysicalDeviceInlineUniformBlockFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceInlineUniformBlockFeaturesExt
}

extension VkPhysicalDeviceInlineUniformBlockPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceInlineUniformBlockPropertiesExt
}

extension VkWriteDescriptorSetInlineUniformBlockEXT: VulkanInStructure {
    public static let type: VkStructureType = .writeDescriptorSetInlineUniformBlockExt
}

extension VkDescriptorPoolInlineUniformBlockCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .descriptorPoolInlineUniformBlockCreateInfoExt
}

extension VkSampleLocationsInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .sampleLocationsInfoExt
}

extension VkRenderPassSampleLocationsBeginInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .renderPassSampleLocationsBeginInfoExt
}

extension VkPipelineSampleLocationsStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineSampleLocationsStateCreateInfoExt
}

extension VkPhysicalDeviceSampleLocationsPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSampleLocationsPropertiesExt
}

extension VkMultisamplePropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .multisamplePropertiesExt
}

extension VkPhysicalDeviceBlendOperationAdvancedFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceBlendOperationAdvancedFeaturesExt
}

extension VkPhysicalDeviceBlendOperationAdvancedPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceBlendOperationAdvancedPropertiesExt
}

extension VkPipelineColorBlendAdvancedStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineColorBlendAdvancedStateCreateInfoExt
}

extension VkPipelineCoverageToColorStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineCoverageToColorStateCreateInfoNv
}

extension VkWriteDescriptorSetAccelerationStructureKHR: VulkanInStructure {
    public static let type: VkStructureType = .writeDescriptorSetAccelerationStructureKhr
}

extension VkAccelerationStructureBuildGeometryInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureBuildGeometryInfoKhr
}

extension VkAccelerationStructureDeviceAddressInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureDeviceAddressInfoKhr
}

extension VkAccelerationStructureGeometryAabbsDataKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureGeometryAabbsDataKhr
}

extension VkAccelerationStructureGeometryInstancesDataKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureGeometryInstancesDataKhr
}

extension VkAccelerationStructureGeometryTrianglesDataKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureGeometryTrianglesDataKhr
}

extension VkAccelerationStructureGeometryKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureGeometryKhr
}

extension VkAccelerationStructureVersionInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureVersionInfoKhr
}

extension VkCopyAccelerationStructureInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .copyAccelerationStructureInfoKhr
}

extension VkCopyAccelerationStructureToMemoryInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .copyAccelerationStructureToMemoryInfoKhr
}

extension VkCopyMemoryToAccelerationStructureInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .copyMemoryToAccelerationStructureInfoKhr
}

extension VkPhysicalDeviceAccelerationStructureFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceAccelerationStructureFeaturesKhr
}

extension VkPhysicalDeviceAccelerationStructurePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceAccelerationStructurePropertiesKhr
}

extension VkAccelerationStructureCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureCreateInfoKhr
}

extension VkAccelerationStructureBuildSizesInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureBuildSizesInfoKhr
}

extension VkPhysicalDeviceRayTracingPipelineFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRayTracingPipelineFeaturesKhr
}

extension VkPhysicalDeviceRayTracingPipelinePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRayTracingPipelinePropertiesKhr
}

extension VkRayTracingPipelineCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .rayTracingPipelineCreateInfoKhr
}

extension VkRayTracingShaderGroupCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .rayTracingShaderGroupCreateInfoKhr
}

extension VkRayTracingPipelineInterfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .rayTracingPipelineInterfaceCreateInfoKhr
}

extension VkPhysicalDeviceRayQueryFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRayQueryFeaturesKhr
}

extension VkPipelineCoverageModulationStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineCoverageModulationStateCreateInfoNv
}

extension VkPhysicalDeviceShaderSMBuiltinsFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderSmBuiltinsFeaturesNv
}

extension VkPhysicalDeviceShaderSMBuiltinsPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderSmBuiltinsPropertiesNv
}

extension VkDrmFormatModifierPropertiesListEXT: VulkanOutStructure {
    public static let type: VkStructureType = .drmFormatModifierPropertiesListExt
}

extension VkPhysicalDeviceImageDrmFormatModifierInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .physicalDeviceImageDrmFormatModifierInfoExt
}

extension VkImageDrmFormatModifierListCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .imageDrmFormatModifierListCreateInfoExt
}

extension VkImageDrmFormatModifierExplicitCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .imageDrmFormatModifierExplicitCreateInfoExt
}

extension VkImageDrmFormatModifierPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .imageDrmFormatModifierPropertiesExt
}

extension VkValidationCacheCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .validationCacheCreateInfoExt
}

extension VkShaderModuleValidationCacheCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .shaderModuleValidationCacheCreateInfoExt
}

extension VkPipelineViewportShadingRateImageStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineViewportShadingRateImageStateCreateInfoNv
}

extension VkPhysicalDeviceShadingRateImageFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShadingRateImageFeaturesNv
}

extension VkPhysicalDeviceShadingRateImagePropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShadingRateImagePropertiesNv
}

extension VkPipelineViewportCoarseSampleOrderStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineViewportCoarseSampleOrderStateCreateInfoNv
}

extension VkRayTracingPipelineCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .rayTracingPipelineCreateInfoNv
}

extension VkAccelerationStructureCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureCreateInfoNv
}

extension VkGeometryNV: VulkanInStructure {
    public static let type: VkStructureType = .geometryNv
}

extension VkGeometryTrianglesNV: VulkanInStructure {
    public static let type: VkStructureType = .geometryTrianglesNv
}

extension VkGeometryAABBNV: VulkanInStructure {
    public static let type: VkStructureType = .geometryAabbNv
}

extension VkBindAccelerationStructureMemoryInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .bindAccelerationStructureMemoryInfoNv
}

extension VkWriteDescriptorSetAccelerationStructureNV: VulkanInStructure {
    public static let type: VkStructureType = .writeDescriptorSetAccelerationStructureNv
}

extension VkAccelerationStructureMemoryRequirementsInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureMemoryRequirementsInfoNv
}

extension VkPhysicalDeviceRayTracingPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRayTracingPropertiesNv
}

extension VkRayTracingShaderGroupCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .rayTracingShaderGroupCreateInfoNv
}

extension VkAccelerationStructureInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureInfoNv
}

extension VkPhysicalDeviceRepresentativeFragmentTestFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRepresentativeFragmentTestFeaturesNv
}

extension VkPipelineRepresentativeFragmentTestStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRepresentativeFragmentTestStateCreateInfoNv
}

extension VkPhysicalDeviceImageViewImageFormatInfoEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceImageViewImageFormatInfoExt
}

extension VkFilterCubicImageViewImageFormatPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .filterCubicImageViewImageFormatPropertiesExt
}

extension VkDeviceQueueGlobalPriorityCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .deviceQueueGlobalPriorityCreateInfoExt
}

extension VkImportMemoryHostPointerInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .importMemoryHostPointerInfoExt
}

extension VkMemoryHostPointerPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .memoryHostPointerPropertiesExt
}

extension VkPhysicalDeviceExternalMemoryHostPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceExternalMemoryHostPropertiesExt
}

extension VkPhysicalDeviceShaderClockFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderClockFeaturesKhr
}

extension VkPipelineCompilerControlCreateInfoAMD: VulkanInStructure {
    public static let type: VkStructureType = .pipelineCompilerControlCreateInfoAmd
}

extension VkCalibratedTimestampInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .calibratedTimestampInfoExt
}

extension VkPhysicalDeviceShaderCorePropertiesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderCorePropertiesAmd
}

extension VkDeviceMemoryOverallocationCreateInfoAMD: VulkanInStructure {
    public static let type: VkStructureType = .deviceMemoryOverallocationCreateInfoAmd
}

extension VkPhysicalDeviceVertexAttributeDivisorPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVertexAttributeDivisorPropertiesExt
}

extension VkPipelineVertexInputDivisorStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineVertexInputDivisorStateCreateInfoExt
}

extension VkPhysicalDeviceVertexAttributeDivisorFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVertexAttributeDivisorFeaturesExt
}

extension VkPipelineCreationFeedbackCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineCreationFeedbackCreateInfoExt
}

extension VkPhysicalDeviceComputeShaderDerivativesFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceComputeShaderDerivativesFeaturesNv
}

extension VkPhysicalDeviceMeshShaderFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMeshShaderFeaturesNv
}

extension VkPhysicalDeviceMeshShaderPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMeshShaderPropertiesNv
}

extension VkPhysicalDeviceFragmentShaderBarycentricFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentShaderBarycentricFeaturesNv
}

extension VkPhysicalDeviceShaderImageFootprintFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderImageFootprintFeaturesNv
}

extension VkPipelineViewportExclusiveScissorStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineViewportExclusiveScissorStateCreateInfoNv
}

extension VkPhysicalDeviceExclusiveScissorFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceExclusiveScissorFeaturesNv
}

extension VkCheckpointDataNV: VulkanOutStructure {
    public static let type: VkStructureType = .checkpointDataNv
}

extension VkQueueFamilyCheckpointPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .queueFamilyCheckpointPropertiesNv
}

extension VkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderIntegerFunctions2FeaturesIntel
}

extension VkQueryPoolPerformanceQueryCreateInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .queryPoolPerformanceQueryCreateInfoIntel
}

extension VkInitializePerformanceApiInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .initializePerformanceApiInfoIntel
}

extension VkPerformanceMarkerInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .performanceMarkerInfoIntel
}

extension VkPerformanceStreamMarkerInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .performanceStreamMarkerInfoIntel
}

extension VkPerformanceOverrideInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .performanceOverrideInfoIntel
}

extension VkPerformanceConfigurationAcquireInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .performanceConfigurationAcquireInfoIntel
}

extension VkPhysicalDevicePCIBusInfoPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePciBusInfoPropertiesExt
}

extension VkDisplayNativeHdrSurfaceCapabilitiesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .displayNativeHdrSurfaceCapabilitiesAmd
}

extension VkSwapchainDisplayNativeHdrCreateInfoAMD: VulkanInStructure {
    public static let type: VkStructureType = .swapchainDisplayNativeHdrCreateInfoAmd
}

extension VkPhysicalDeviceShaderTerminateInvocationFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderTerminateInvocationFeaturesKhr
}

#if os(iOS) || os(macOS)
    extension VkMetalSurfaceCreateInfoEXT: VulkanInStructure {
        public static let type: VkStructureType = .metalSurfaceCreateInfoExt
    }
#endif

extension VkPhysicalDeviceFragmentDensityMapFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentDensityMapFeaturesExt
}

extension VkPhysicalDeviceFragmentDensityMapPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentDensityMapPropertiesExt
}

extension VkRenderPassFragmentDensityMapCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .renderPassFragmentDensityMapCreateInfoExt
}

extension VkPhysicalDeviceSubgroupSizeControlPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSubgroupSizeControlPropertiesExt
}

extension VkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT: VulkanOutStructure {
    public static let type: VkStructureType = .pipelineShaderStageRequiredSubgroupSizeCreateInfoExt
}

extension VkPhysicalDeviceSubgroupSizeControlFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSubgroupSizeControlFeaturesExt
}

extension VkFragmentShadingRateAttachmentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .fragmentShadingRateAttachmentInfoKhr
}

extension VkPipelineFragmentShadingRateStateCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .pipelineFragmentShadingRateStateCreateInfoKhr
}

extension VkPhysicalDeviceFragmentShadingRatePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentShadingRatePropertiesKhr
}

extension VkPhysicalDeviceFragmentShadingRateFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentShadingRateFeaturesKhr
}

extension VkPhysicalDeviceFragmentShadingRateKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentShadingRateKhr
}

extension VkPhysicalDeviceShaderCoreProperties2AMD: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderCoreProperties2Amd
}

extension VkPhysicalDeviceCoherentMemoryFeaturesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceCoherentMemoryFeaturesAmd
}

extension VkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderImageAtomicInt64FeaturesExt
}

extension VkPhysicalDeviceMemoryBudgetPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMemoryBudgetPropertiesExt
}

extension VkPhysicalDeviceMemoryPriorityFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMemoryPriorityFeaturesExt
}

extension VkMemoryPriorityAllocateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .memoryPriorityAllocateInfoExt
}

extension VkSurfaceProtectedCapabilitiesKHR: VulkanInStructure {
    public static let type: VkStructureType = .surfaceProtectedCapabilitiesKhr
}

extension VkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDedicatedAllocationImageAliasingFeaturesNv
}

extension VkPhysicalDeviceBufferDeviceAddressFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceBufferDeviceAddressFeaturesExt
}

extension VkBufferDeviceAddressCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .bufferDeviceAddressCreateInfoExt
}

extension VkPhysicalDeviceToolPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceToolPropertiesExt
}

extension VkValidationFeaturesEXT: VulkanInStructure {
    public static let type: VkStructureType = .validationFeaturesExt
}

extension VkPhysicalDeviceCooperativeMatrixFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceCooperativeMatrixFeaturesNv
}

extension VkCooperativeMatrixPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .cooperativeMatrixPropertiesNv
}

extension VkPhysicalDeviceCooperativeMatrixPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceCooperativeMatrixPropertiesNv
}

extension VkPhysicalDeviceCoverageReductionModeFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceCoverageReductionModeFeaturesNv
}

extension VkPipelineCoverageReductionStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineCoverageReductionStateCreateInfoNv
}

extension VkFramebufferMixedSamplesCombinationNV: VulkanOutStructure {
    public static let type: VkStructureType = .framebufferMixedSamplesCombinationNv
}

extension VkPhysicalDeviceFragmentShaderInterlockFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentShaderInterlockFeaturesExt
}

extension VkPhysicalDeviceYcbcrImageArraysFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceYcbcrImageArraysFeaturesExt
}

extension VkPhysicalDeviceProvokingVertexFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceProvokingVertexFeaturesExt
}

extension VkPipelineRasterizationProvokingVertexStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRasterizationProvokingVertexStateCreateInfoExt
}

extension VkPhysicalDeviceProvokingVertexPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceProvokingVertexPropertiesExt
}

#if os(Windows)
    extension VkSurfaceFullScreenExclusiveInfoEXT: VulkanInStructure {
        public static let type: VkStructureType = .surfaceFullScreenExclusiveInfoExt
    }

    extension VkSurfaceCapabilitiesFullScreenExclusiveEXT: VulkanOutStructure {
        public static let type: VkStructureType = .surfaceCapabilitiesFullScreenExclusiveExt
    }

    extension VkSurfaceFullScreenExclusiveWin32InfoEXT: VulkanInStructure {
        public static let type: VkStructureType = .surfaceFullScreenExclusiveWin32InfoExt
    }
#endif

extension VkHeadlessSurfaceCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .headlessSurfaceCreateInfoExt
}

extension VkPhysicalDeviceLineRasterizationFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceLineRasterizationFeaturesExt
}

extension VkPipelineRasterizationLineStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineRasterizationLineStateCreateInfoExt
}

extension VkPhysicalDeviceLineRasterizationPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceLineRasterizationPropertiesExt
}

extension VkPhysicalDeviceShaderAtomicFloatFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderAtomicFloatFeaturesExt
}

extension VkPhysicalDeviceIndexTypeUint8FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceIndexTypeUint8FeaturesExt
}

extension VkPhysicalDeviceExtendedDynamicStateFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceExtendedDynamicStateFeaturesExt
}

extension VkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePipelineExecutablePropertiesFeaturesKhr
}

extension VkPipelineInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .pipelineInfoKhr
}

extension VkPipelineExecutablePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .pipelineExecutablePropertiesKhr
}

extension VkPipelineExecutableInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .pipelineExecutableInfoKhr
}

extension VkPipelineExecutableStatisticKHR: VulkanOutStructure {
    public static let type: VkStructureType = .pipelineExecutableStatisticKhr
}

extension VkPipelineExecutableInternalRepresentationKHR: VulkanOutStructure {
    public static let type: VkStructureType = .pipelineExecutableInternalRepresentationKhr
}

extension VkPhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderDemoteToHelperInvocationFeaturesExt
}

extension VkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDeviceGeneratedCommandsPropertiesNv
}

extension VkGraphicsShaderGroupCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .graphicsShaderGroupCreateInfoNv
}

extension VkGraphicsPipelineShaderGroupsCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .graphicsPipelineShaderGroupsCreateInfoNv
}

extension VkIndirectCommandsLayoutTokenNV: VulkanInStructure {
    public static let type: VkStructureType = .indirectCommandsLayoutTokenNv
}

extension VkIndirectCommandsLayoutCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .indirectCommandsLayoutCreateInfoNv
}

extension VkGeneratedCommandsInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .generatedCommandsInfoNv
}

extension VkGeneratedCommandsMemoryRequirementsInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .generatedCommandsMemoryRequirementsInfoNv
}

extension VkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDeviceGeneratedCommandsFeaturesNv
}

extension VkPhysicalDeviceInheritedViewportScissorFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceInheritedViewportScissorFeaturesNv
}

extension VkCommandBufferInheritanceViewportScissorInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .commandBufferInheritanceViewportScissorInfoNv
}

extension VkPhysicalDeviceTexelBufferAlignmentFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceTexelBufferAlignmentFeaturesExt
}

extension VkPhysicalDeviceTexelBufferAlignmentPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceTexelBufferAlignmentPropertiesExt
}

extension VkCommandBufferInheritanceRenderPassTransformInfoQCOM: VulkanOutStructure {
    public static let type: VkStructureType = .commandBufferInheritanceRenderPassTransformInfoQcom
}

extension VkRenderPassTransformBeginInfoQCOM: VulkanOutStructure {
    public static let type: VkStructureType = .renderPassTransformBeginInfoQcom
}

extension VkPhysicalDeviceDeviceMemoryReportFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDeviceMemoryReportFeaturesExt
}

extension VkDeviceDeviceMemoryReportCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .deviceDeviceMemoryReportCreateInfoExt
}

extension VkDeviceMemoryReportCallbackDataEXT: VulkanOutStructure {
    public static let type: VkStructureType = .deviceMemoryReportCallbackDataExt
}

extension VkPhysicalDeviceRobustness2FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRobustness2FeaturesExt
}

extension VkPhysicalDeviceRobustness2PropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRobustness2PropertiesExt
}

extension VkSamplerCustomBorderColorCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .samplerCustomBorderColorCreateInfoExt
}

extension VkPhysicalDeviceCustomBorderColorPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceCustomBorderColorPropertiesExt
}

extension VkPhysicalDeviceCustomBorderColorFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceCustomBorderColorFeaturesExt
}

extension VkPipelineLibraryCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .pipelineLibraryCreateInfoKhr
}

extension VkPhysicalDevicePrivateDataFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePrivateDataFeaturesExt
}

extension VkDevicePrivateDataCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .devicePrivateDataCreateInfoExt
}

extension VkPrivateDataSlotCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .privateDataSlotCreateInfoExt
}

extension VkPhysicalDevicePipelineCreationCacheControlFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevicePipelineCreationCacheControlFeaturesExt
}

extension VkPhysicalDeviceDiagnosticsConfigFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDiagnosticsConfigFeaturesNv
}

extension VkDeviceDiagnosticsConfigCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .deviceDiagnosticsConfigCreateInfoNv
}

extension VkMemoryBarrier2KHR: VulkanInStructure {
    public static let type: VkStructureType = .memoryBarrier2Khr
}

extension VkBufferMemoryBarrier2KHR: VulkanInStructure {
    public static let type: VkStructureType = .bufferMemoryBarrier2Khr
}

extension VkImageMemoryBarrier2KHR: VulkanInStructure {
    public static let type: VkStructureType = .imageMemoryBarrier2Khr
}

extension VkDependencyInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .dependencyInfoKhr
}

extension VkSubmitInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .submitInfo2Khr
}

extension VkSemaphoreSubmitInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .semaphoreSubmitInfoKhr
}

extension VkCommandBufferSubmitInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .commandBufferSubmitInfoKhr
}

extension VkPhysicalDeviceSynchronization2FeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSynchronization2FeaturesKhr
}

extension VkQueueFamilyCheckpointProperties2NV: VulkanOutStructure {
    public static let type: VkStructureType = .queueFamilyCheckpointProperties2Nv
}

extension VkCheckpointData2NV: VulkanOutStructure {
    public static let type: VkStructureType = .checkpointData2Nv
}

extension VkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceShaderSubgroupUniformControlFlowFeaturesKhr
}

extension VkPhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceZeroInitializeWorkgroupMemoryFeaturesKhr
}

extension VkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentShadingRateEnumsPropertiesNv
}

extension VkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentShadingRateEnumsFeaturesNv
}

extension VkPipelineFragmentShadingRateEnumStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .pipelineFragmentShadingRateEnumStateCreateInfoNv
}

extension VkAccelerationStructureGeometryMotionTrianglesDataNV: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureGeometryMotionTrianglesDataNv
}

extension VkPhysicalDeviceRayTracingMotionBlurFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceRayTracingMotionBlurFeaturesNv
}

extension VkAccelerationStructureMotionInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .accelerationStructureMotionInfoNv
}

extension VkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceYcbcr2Plane444FormatsFeaturesExt
}

extension VkPhysicalDeviceFragmentDensityMap2FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentDensityMap2FeaturesExt
}

extension VkPhysicalDeviceFragmentDensityMap2PropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceFragmentDensityMap2PropertiesExt
}

extension VkCopyCommandTransformInfoQCOM: VulkanInStructure {
    public static let type: VkStructureType = .copyCommandTransformInfoQcom
}

extension VkPhysicalDeviceImageRobustnessFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceImageRobustnessFeaturesExt
}

extension VkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKhr
}

extension VkCopyBufferInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .copyBufferInfo2Khr
}

extension VkCopyImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .copyImageInfo2Khr
}

extension VkCopyBufferToImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .copyBufferToImageInfo2Khr
}

extension VkCopyImageToBufferInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .copyImageToBufferInfo2Khr
}

extension VkBlitImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .blitImageInfo2Khr
}

extension VkResolveImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .resolveImageInfo2Khr
}

extension VkBufferCopy2KHR: VulkanInStructure {
    public static let type: VkStructureType = .bufferCopy2Khr
}

extension VkImageCopy2KHR: VulkanInStructure {
    public static let type: VkStructureType = .imageCopy2Khr
}

extension VkImageBlit2KHR: VulkanInStructure {
    public static let type: VkStructureType = .imageBlit2Khr
}

extension VkBufferImageCopy2KHR: VulkanInStructure {
    public static let type: VkStructureType = .bufferImageCopy2Khr
}

extension VkImageResolve2KHR: VulkanInStructure {
    public static let type: VkStructureType = .imageResolve2Khr
}

extension VkPhysicalDevice4444FormatsFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDevice4444FormatsFeaturesExt
}

#if canImport(CDirectFB)
    extension VkDirectfbSurfaceCreateInfoEXT: VulkanInStructure {
        public static let type: VkStructureType = .directfbSurfaceCreateInfoExt
    }
#endif

extension VkPhysicalDeviceMutableDescriptorTypeFeaturesVALVE: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMutableDescriptorTypeFeaturesValve
}

extension VkMutableDescriptorTypeCreateInfoVALVE: VulkanInStructure {
    public static let type: VkStructureType = .mutableDescriptorTypeCreateInfoValve
}

extension VkPhysicalDeviceVertexInputDynamicStateFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceVertexInputDynamicStateFeaturesExt
}

extension VkVertexInputBindingDescription2EXT: VulkanOutStructure {
    public static let type: VkStructureType = .vertexInputBindingDescription2Ext
}

extension VkVertexInputAttributeDescription2EXT: VulkanOutStructure {
    public static let type: VkStructureType = .vertexInputAttributeDescription2Ext
}

extension VkPhysicalDeviceDrmPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceDrmPropertiesExt
}

extension VkSubpassShadingPipelineCreateInfoHUAWEI: VulkanOutStructure {
    public static let type: VkStructureType = .subpassShadingPipelineCreateInfoHuawei
}

extension VkPhysicalDeviceSubpassShadingFeaturesHUAWEI: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSubpassShadingFeaturesHuawei
}

extension VkPhysicalDeviceSubpassShadingPropertiesHUAWEI: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceSubpassShadingPropertiesHuawei
}

extension VkPhysicalDeviceExtendedDynamicState2FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceExtendedDynamicState2FeaturesExt
}

extension VkPhysicalDeviceColorWriteEnableFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceColorWriteEnableFeaturesExt
}

extension VkPipelineColorWriteCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .pipelineColorWriteCreateInfoExt
}

extension VkPhysicalDeviceGlobalPriorityQueryFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceGlobalPriorityQueryFeaturesExt
}

extension VkQueueFamilyGlobalPriorityPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .queueFamilyGlobalPriorityPropertiesExt
}

extension VkPhysicalDeviceMultiDrawFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMultiDrawFeaturesExt
}

extension VkPhysicalDeviceMultiDrawPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .physicalDeviceMultiDrawPropertiesExt
}
