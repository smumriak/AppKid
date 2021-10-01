//
//  CVulkan_umbrella.h
//  Volcano
//
//  Created by Serhii Mumriak on 15.05.2020.
//

#ifndef CVulkan_umbrella_h
#define CVulkan_umbrella_h 1

#include "VulkanOptionSets.h"
#include "VulkanEnums.h"

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

#if defined(__linux__)

#define VK_USE_PLATFORM_XLIB_KHR
#define VK_USE_PLATFORM_XCB_KHR
#define VK_USE_PLATFORM_WAYLAND_KHR
#include <X11/Xlib.h>
#include <vulkan/vulkan.h>
#include <vulkan/vulkan_xlib.h>
#include <vulkan/vulkan_xcb.h>
#include <vulkan/vulkan_wayland.h>

#else

#define VK_USE_PLATFORM_MACOS_MVK
#include <vulkan/vulkan.h>
#endif

#ifndef __cplusplus
static inline void * cVulkanGetInstanceProcAddr(VkInstance instance, const char* pName)
{
    return vkGetInstanceProcAddr(instance, pName);
}

static inline void * cVulkanGetDeviceProcAddr(VkDevice device, const char* pName)
{
    return vkGetDeviceProcAddr(device, pName);
}
#endif

#endif
