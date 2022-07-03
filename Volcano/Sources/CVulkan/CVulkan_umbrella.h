//
//  CVulkan_umbrella.h
//  Volcano
//
//  Created by Serhii Mumriak on 15.05.2020.
//

#ifndef CVulkan_umbrella_h
#define CVulkan_umbrella_h 1

#if __linux__

#define VK_USE_PLATFORM_XLIB_KHR
#define VK_USE_PLATFORM_XCB_KHR
#define VK_USE_PLATFORM_WAYLAND_KHR

#elif __APPLE__

#include <TargetConditionals.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MACCATALYST || TARGET_OS_IPHONE

#define VK_USE_PLATFORM_IOS_MVK

#elif TARGET_OS_MAC

#define VK_USE_PLATFORM_MACOS_MVK

#endif

#define VK_USE_PLATFORM_METAL_EXT

#endif

#include "VulkanOptionSets.h"
#include "VulkanEnums.h"
#include "VulkanStructs.h"

#include <vulkan/vulkan.h>

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
