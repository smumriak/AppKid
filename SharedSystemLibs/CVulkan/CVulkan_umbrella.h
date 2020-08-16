//
//  CVulkan_umbrella.h
//  ContentAnimation
//
//  Created by Serhii Mumriak on 15.05.2020.
//

#ifndef CVulkan_umbrella_h
#define CVulkan_umbrella_h 1

struct VkInstance_T {};
struct VkPhysicalDevice_T {};
struct VkDevice_T {};
struct VkQueue_T {};
struct VkSemaphore_T {};
struct VkCommandBuffer_T {};
struct VkFence_T {};
struct VkDeviceMemory_T {};
struct VkBuffer_T {};
struct VkImage_T {};
struct VkEvent_T {};
struct VkQueryPool_T {};
struct VkBufferView_T {};
struct VkImageView_T {};
struct VkShaderModule_T {};
struct VkPipelineCache_T {};
struct VkPipelineLayout_T {};
struct VkRenderPass_T {};
struct VkPipeline_T {};
struct VkDescriptorSetLayout_T {};
struct VkSampler_T {};
struct VkDescriptorPool_T {};
struct VkDescriptorSet_T {};
struct VkFramebuffer_T {};
struct VkCommandPool_T {};
struct VkSurfaceKHR_T {};
struct VkSwapchainKHR_T {};

#include "../CCore/CCore_umbrella.h"

AK_EXTISTING_OPTIONS(VkFormatFeatureFlagBits);
AK_EXTISTING_OPTIONS(VkImageUsageFlagBits);
AK_EXTISTING_OPTIONS(VkImageCreateFlagBits);
AK_EXTISTING_OPTIONS(VkSampleCountFlagBits);
AK_EXTISTING_OPTIONS(VkQueueFlagBits);
AK_EXTISTING_OPTIONS(VkMemoryPropertyFlagBits);
AK_EXTISTING_OPTIONS(VkMemoryHeapFlagBits);
AK_EXTISTING_OPTIONS(VkDeviceQueueCreateFlagBits);
AK_EXTISTING_OPTIONS(VkPipelineStageFlagBits);
AK_EXTISTING_OPTIONS(VkImageAspectFlagBits);
AK_EXTISTING_OPTIONS(VkSparseImageFormatFlagBits);
AK_EXTISTING_OPTIONS(VkSparseMemoryBindFlagBits);
AK_EXTISTING_OPTIONS(VkFenceCreateFlagBits);
AK_EXTISTING_OPTIONS(VkQueryPipelineStatisticFlagBits);
AK_EXTISTING_OPTIONS(VkQueryResultFlagBits);
AK_EXTISTING_OPTIONS(VkBufferCreateFlagBits);
AK_EXTISTING_OPTIONS(VkBufferUsageFlagBits);
AK_EXTISTING_OPTIONS(VkImageViewCreateFlagBits);
AK_EXTISTING_OPTIONS(VkShaderModuleCreateFlagBits);
AK_EXTISTING_OPTIONS(VkPipelineCacheCreateFlagBits);
AK_EXTISTING_OPTIONS(VkPipelineCreateFlagBits);
AK_EXTISTING_OPTIONS(VkPipelineShaderStageCreateFlagBits);
AK_EXTISTING_OPTIONS(VkShaderStageFlagBits);
AK_EXTISTING_OPTIONS(VkCullModeFlagBits);
AK_EXTISTING_OPTIONS(VkColorComponentFlagBits);
AK_EXTISTING_OPTIONS(VkSamplerCreateFlagBits);
AK_EXTISTING_OPTIONS(VkDescriptorSetLayoutCreateFlagBits);
AK_EXTISTING_OPTIONS(VkDescriptorPoolCreateFlagBits);
AK_EXTISTING_OPTIONS(VkFramebufferCreateFlagBits);
AK_EXTISTING_OPTIONS(VkRenderPassCreateFlagBits);
AK_EXTISTING_OPTIONS(VkAttachmentDescriptionFlagBits);
AK_EXTISTING_OPTIONS(VkSubpassDescriptionFlagBits);
AK_EXTISTING_OPTIONS(VkAccessFlagBits);
AK_EXTISTING_OPTIONS(VkDependencyFlagBits);
AK_EXTISTING_OPTIONS(VkCommandPoolCreateFlagBits);
AK_EXTISTING_OPTIONS(VkCommandPoolResetFlagBits);
AK_EXTISTING_OPTIONS(VkCommandBufferUsageFlagBits);
AK_EXTISTING_OPTIONS(VkQueryControlFlagBits);
AK_EXTISTING_OPTIONS(VkCommandBufferResetFlagBits);
AK_EXTISTING_OPTIONS(VkStencilFaceFlagBits);

#if defined(__linux__)

#define VK_USE_PLATFORM_XLIB_KHR
#include <X11/Xlib.h>
#include <vulkan/vulkan.h>
#include <vulkan/vulkan_xlib.h>

#else

#define VK_USE_PLATFORM_MACOS_MVK
#include <vulkan/vulkan.h>
#endif

static void * cVulkanGetInstanceProcAddr(VkInstance instance, const char* pName)
{
    return vkGetInstanceProcAddr(instance, pName);
}
static void * cVulkanGetDeviceProcAddr(VkDevice device, const char* pName)
{
    return vkGetDeviceProcAddr(device, pName);
}

#endif
