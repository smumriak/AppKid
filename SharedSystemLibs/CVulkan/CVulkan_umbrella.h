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

#include <vulkan/vulkan.h>

#if defined(__linux__)
#define VK_USE_PLATFORM_XLIB_KHR

#include <X11/Xlib.h>
#include <vulkan/vulkan_xlib.h>
#endif

#include "../CCore/CCore_umbrella.h"

static void * cVulkanGetInstanceProcAddr(VkInstance instance, const char* pName)
{
    return vkGetInstanceProcAddr(instance, pName);
}
static void * cVulkanGetDeviceProcAddr(VkDevice device, const char* pName)
{
    return vkGetDeviceProcAddr(device, pName);
}

#endif
