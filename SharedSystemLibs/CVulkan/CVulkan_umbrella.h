//
//  CVulkan_umbrella.h
//  ContentAnimation
//
//  Created by Serhii Mumriak on 15.05.2020.
//

#ifndef CVulkan_umbrella_h
#define CVulkan_umbrella_h 1

struct VkInstance_T {};

#include <vulkan/vulkan.h>

#if defined(__linux__)
#define VK_USE_PLATFORM_XLIB_KHR

#include <X11/Xlib.h>
#include <vulkan/vulkan_xlib.h>
#endif

#include "../CCore/CCore_umbrella.h"

#endif
