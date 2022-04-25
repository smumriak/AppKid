#ifndef VulkanMemoryAllocatorAdapted_h
#define VulkanMemoryAllocatorAdapted_h 1

#ifndef __cplusplus

#include "../../../../SharedSystemLibs/CCore/include/CCore.h"

struct VmaAllocator_T {};
struct VmaPool_T {};
struct VmaAllocation_T {};
struct VmaDefragmentationContext_T {};

AK_EXISTING_OPTIONS(VmaAllocatorCreateFlagBits);
AK_EXISTING_OPTIONS(VmaAllocationCreateFlagBits);
AK_EXISTING_OPTIONS(VmaPoolCreateFlagBits);
AK_EXISTING_OPTIONS(VmaDefragmentationFlagBits);
AK_EXISTING_OPTIONS(VmaRecordFlagBits);

AK_EXISTING_ENUM(VmaMemoryUsage);

#endif

#include "../../CVulkan/CVulkan_umbrella.h"
#include <VulkanMemoryAllocatorAdaptor.h>

#endif
