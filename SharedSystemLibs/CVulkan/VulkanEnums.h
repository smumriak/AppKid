//
//  VulkanEnums.h
//  Volcano
//
//  Created by Serhii Mumriak on 17.08.2020.
//

#ifndef VulkanEnums_h
#define VulkanEnums_h 1

#include "../CCore/include/CCore.h"

AK_EXISTING_ENUM(VkAccelerationStructureBuildTypeKHR);
AK_EXISTING_ENUM(VkAccelerationStructureCompatibilityKHR);
AK_EXISTING_ENUM(VkAccelerationStructureMemoryRequirementsTypeNV);
AK_EXISTING_ENUM(VkAccelerationStructureMotionInstanceTypeNV);
AK_EXISTING_ENUM(VkAccelerationStructureTypeKHR);
AK_EXISTING_ENUM(VkAttachmentLoadOp);
AK_EXISTING_ENUM(VkAttachmentStoreOp);
AK_EXISTING_ENUM(VkBlendFactor);
AK_EXISTING_ENUM(VkBlendOp);
AK_EXISTING_ENUM(VkBlendOverlapEXT);
AK_EXISTING_ENUM(VkBorderColor);
AK_EXISTING_ENUM(VkBuildAccelerationStructureModeKHR);
AK_EXISTING_ENUM(VkChromaLocation);
AK_EXISTING_ENUM(VkCoarseSampleOrderTypeNV);
AK_EXISTING_ENUM(VkColorSpaceKHR);
AK_EXISTING_ENUM(VkCommandBufferLevel);
AK_EXISTING_ENUM(VkCompareOp);
AK_EXISTING_ENUM(VkComponentSwizzle);
AK_EXISTING_ENUM(VkComponentTypeNV);
AK_EXISTING_ENUM(VkConservativeRasterizationModeEXT);
AK_EXISTING_ENUM(VkCopyAccelerationStructureModeKHR);
AK_EXISTING_ENUM(VkCoverageModulationModeNV);
AK_EXISTING_ENUM(VkCoverageReductionModeNV);
AK_EXISTING_ENUM(VkDebugReportObjectTypeEXT);
AK_EXISTING_ENUM(VkDescriptorType);
AK_EXISTING_ENUM(VkDescriptorUpdateTemplateType);
AK_EXISTING_ENUM(VkDeviceEventTypeEXT);
AK_EXISTING_ENUM(VkDeviceMemoryReportEventTypeEXT);
AK_EXISTING_ENUM(VkDiscardRectangleModeEXT);
AK_EXISTING_ENUM(VkDisplayEventTypeEXT);
AK_EXISTING_ENUM(VkDisplayPowerStateEXT);
AK_EXISTING_ENUM(VkDriverId);
AK_EXISTING_ENUM(VkDynamicState);
AK_EXISTING_ENUM(VkFilter);
AK_EXISTING_ENUM(VkFormat);
AK_EXISTING_ENUM(VkFragmentShadingRateCombinerOpKHR);
AK_EXISTING_ENUM(VkFragmentShadingRateNV);
AK_EXISTING_ENUM(VkFragmentShadingRateTypeNV);
AK_EXISTING_ENUM(VkFrontFace);
#ifdef VK_USE_PLATFORM_WIN32_KHR
AK_EXISTING_ENUM(VkFullScreenExclusiveEXT);
#endif
AK_EXISTING_ENUM(VkGeometryTypeKHR);
AK_EXISTING_ENUM(VkImageLayout);
AK_EXISTING_ENUM(VkImageTiling);
AK_EXISTING_ENUM(VkImageType);
AK_EXISTING_ENUM(VkImageViewType);
AK_EXISTING_ENUM(VkIndexType);
AK_EXISTING_ENUM(VkIndirectCommandsTokenTypeNV);
AK_EXISTING_ENUM(VkInternalAllocationType);
AK_EXISTING_ENUM(VkLineRasterizationModeEXT);
AK_EXISTING_ENUM(VkLogicOp);
AK_EXISTING_ENUM(VkMemoryOverallocationBehaviorAMD);
AK_EXISTING_ENUM(VkObjectType);
AK_EXISTING_ENUM(VkPerformanceConfigurationTypeINTEL);
AK_EXISTING_ENUM(VkPerformanceCounterScopeKHR);
AK_EXISTING_ENUM(VkPerformanceCounterStorageKHR);
AK_EXISTING_ENUM(VkPerformanceCounterUnitKHR);
AK_EXISTING_ENUM(VkPerformanceOverrideTypeINTEL);
AK_EXISTING_ENUM(VkPerformanceParameterTypeINTEL);
AK_EXISTING_ENUM(VkPerformanceValueTypeINTEL);
AK_EXISTING_ENUM(VkPhysicalDeviceType);
AK_EXISTING_ENUM(VkPipelineBindPoint);
AK_EXISTING_ENUM(VkPipelineCacheHeaderVersion);
AK_EXISTING_ENUM(VkPipelineExecutableStatisticFormatKHR);
AK_EXISTING_ENUM(VkPointClippingBehavior);
AK_EXISTING_ENUM(VkPolygonMode);
AK_EXISTING_ENUM(VkPresentModeKHR);
AK_EXISTING_ENUM(VkPrimitiveTopology);
AK_EXISTING_ENUM(VkProvokingVertexModeEXT);
AK_EXISTING_ENUM(VkQueryPoolSamplingModeINTEL);
AK_EXISTING_ENUM(VkQueryType);
AK_EXISTING_ENUM(VkQueueGlobalPriorityKHR);
AK_EXISTING_ENUM(VkRasterizationOrderAMD);
AK_EXISTING_ENUM(VkRayTracingShaderGroupTypeKHR);
AK_EXISTING_ENUM(VkResult);
AK_EXISTING_ENUM(VkSamplerAddressMode);
AK_EXISTING_ENUM(VkSamplerMipmapMode);
AK_EXISTING_ENUM(VkSamplerReductionMode);
AK_EXISTING_ENUM(VkSamplerYcbcrModelConversion);
AK_EXISTING_ENUM(VkSamplerYcbcrRange);
AK_EXISTING_ENUM(VkScopeNV);
AK_EXISTING_ENUM(VkSemaphoreType);
AK_EXISTING_ENUM(VkShaderFloatControlsIndependence);
AK_EXISTING_ENUM(VkShaderGroupShaderKHR);
AK_EXISTING_ENUM(VkShaderInfoTypeAMD);
AK_EXISTING_ENUM(VkShadingRatePaletteEntryNV);
AK_EXISTING_ENUM(VkSharingMode);
AK_EXISTING_ENUM(VkStencilOp);
AK_EXISTING_ENUM(VkStructureType);
AK_EXISTING_ENUM(VkSubpassContents);
AK_EXISTING_ENUM(VkSystemAllocationScope);
AK_EXISTING_ENUM(VkTessellationDomainOrigin);
AK_EXISTING_ENUM(VkTimeDomainEXT);
AK_EXISTING_ENUM(VkValidationCacheHeaderVersionEXT);
AK_EXISTING_ENUM(VkValidationCheckEXT);
AK_EXISTING_ENUM(VkValidationFeatureDisableEXT);
AK_EXISTING_ENUM(VkValidationFeatureEnableEXT);
AK_EXISTING_ENUM(VkVendorId);
AK_EXISTING_ENUM(VkVertexInputRate);
AK_EXISTING_ENUM(VkViewportCoordinateSwizzleNV);

#endif /* VulkanEnums_h */
