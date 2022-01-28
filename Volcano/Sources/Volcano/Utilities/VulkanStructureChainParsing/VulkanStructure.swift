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
    @_transparent
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

extension VkAccelerationStructureBuildGeometryInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR
}

extension VkAccelerationStructureBuildSizesInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR
}

extension VkAccelerationStructureCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR
}

extension VkAccelerationStructureCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_NV
}

extension VkAccelerationStructureDeviceAddressInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR
}

extension VkAccelerationStructureGeometryAabbsDataKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR
}

extension VkAccelerationStructureGeometryInstancesDataKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR
}

extension VkAccelerationStructureGeometryKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR
}

extension VkAccelerationStructureGeometryMotionTrianglesDataNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_MOTION_TRIANGLES_DATA_NV
}

extension VkAccelerationStructureGeometryTrianglesDataKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR
}

extension VkAccelerationStructureInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_INFO_NV
}

extension VkAccelerationStructureMemoryRequirementsInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_INFO_NV
}

extension VkAccelerationStructureMotionInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MOTION_INFO_NV
}

extension VkAccelerationStructureVersionInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_VERSION_INFO_KHR
}

extension VkAcquireNextImageInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACQUIRE_NEXT_IMAGE_INFO_KHR
}

extension VkAcquireProfilingLockInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ACQUIRE_PROFILING_LOCK_INFO_KHR
}

#if VOLCANO_PLATFORM_ANDROID
extension VkAndroidHardwareBufferFormatProperties2ANDROID: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_FORMAT_PROPERTIES_2_ANDROID
}
#endif

#if VOLCANO_PLATFORM_ANDROID
extension VkAndroidHardwareBufferFormatPropertiesANDROID: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_FORMAT_PROPERTIES_ANDROID
}
#endif

#if VOLCANO_PLATFORM_ANDROID
extension VkAndroidHardwareBufferPropertiesANDROID: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_PROPERTIES_ANDROID
}
#endif

#if VOLCANO_PLATFORM_ANDROID
extension VkAndroidHardwareBufferUsageANDROID: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_USAGE_ANDROID
}
#endif

#if VOLCANO_PLATFORM_ANDROID
extension VkAndroidSurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR
}
#endif

extension VkApplicationInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_APPLICATION_INFO
}

extension VkAttachmentDescription2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2
}

extension VkAttachmentDescriptionStencilLayout: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_STENCIL_LAYOUT
}

extension VkAttachmentReference2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2
}

extension VkAttachmentReferenceStencilLayout: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_STENCIL_LAYOUT
}

extension VkAttachmentSampleCountInfoAMD: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_ATTACHMENT_SAMPLE_COUNT_INFO_AMD
}

extension VkBindAccelerationStructureMemoryInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_ACCELERATION_STRUCTURE_MEMORY_INFO_NV
}

extension VkBindBufferMemoryDeviceGroupInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_DEVICE_GROUP_INFO
}

extension VkBindBufferMemoryInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_INFO
}

extension VkBindImageMemoryDeviceGroupInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_DEVICE_GROUP_INFO
}

extension VkBindImageMemoryInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_INFO
}

extension VkBindImageMemorySwapchainInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_SWAPCHAIN_INFO_KHR
}

extension VkBindImagePlaneMemoryInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_IMAGE_PLANE_MEMORY_INFO
}

extension VkBindSparseInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BIND_SPARSE_INFO
}

extension VkBlitImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BLIT_IMAGE_INFO_2_KHR
}

extension VkBufferCopy2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_COPY_2_KHR
}

extension VkBufferCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO
}

extension VkBufferDeviceAddressCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_CREATE_INFO_EXT
}

extension VkBufferDeviceAddressInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO
}

extension VkBufferImageCopy2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_IMAGE_COPY_2_KHR
}

extension VkBufferMemoryBarrier: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER
}

extension VkBufferMemoryBarrier2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER_2_KHR
}

extension VkBufferMemoryRequirementsInfo2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_REQUIREMENTS_INFO_2
}

extension VkBufferOpaqueCaptureAddressCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_OPAQUE_CAPTURE_ADDRESS_CREATE_INFO
}

extension VkBufferViewCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO
}

extension VkCalibratedTimestampInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_CALIBRATED_TIMESTAMP_INFO_EXT
}

extension VkCheckpointData2NV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_CHECKPOINT_DATA_2_NV
}

extension VkCheckpointDataNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_CHECKPOINT_DATA_NV
}

extension VkCommandBufferAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
}

extension VkCommandBufferBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
}

extension VkCommandBufferInheritanceConditionalRenderingInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_CONDITIONAL_RENDERING_INFO_EXT
}

extension VkCommandBufferInheritanceInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO
}

extension VkCommandBufferInheritanceRenderPassTransformInfoQCOM: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_RENDER_PASS_TRANSFORM_INFO_QCOM
}

extension VkCommandBufferInheritanceRenderingInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_RENDERING_INFO_KHR
}

extension VkCommandBufferInheritanceViewportScissorInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_VIEWPORT_SCISSOR_INFO_NV
}

extension VkCommandBufferSubmitInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO_KHR
}

extension VkCommandPoolCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
}

extension VkComputePipelineCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO
}

extension VkConditionalRenderingBeginInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_CONDITIONAL_RENDERING_BEGIN_INFO_EXT
}

extension VkCooperativeMatrixPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COOPERATIVE_MATRIX_PROPERTIES_NV
}

extension VkCopyAccelerationStructureInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_INFO_KHR
}

extension VkCopyAccelerationStructureToMemoryInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_TO_MEMORY_INFO_KHR
}

extension VkCopyBufferInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_BUFFER_INFO_2_KHR
}

extension VkCopyBufferToImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_BUFFER_TO_IMAGE_INFO_2_KHR
}

extension VkCopyCommandTransformInfoQCOM: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_COMMAND_TRANSFORM_INFO_QCOM
}

extension VkCopyDescriptorSet: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET
}

extension VkCopyImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_IMAGE_INFO_2_KHR
}

extension VkCopyImageToBufferInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_IMAGE_TO_BUFFER_INFO_2_KHR
}

extension VkCopyMemoryToAccelerationStructureInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_COPY_MEMORY_TO_ACCELERATION_STRUCTURE_INFO_KHR
}

extension VkCuFunctionCreateInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_CU_FUNCTION_CREATE_INFO_NVX
}

extension VkCuLaunchInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_CU_LAUNCH_INFO_NVX
}

extension VkCuModuleCreateInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_CU_MODULE_CREATE_INFO_NVX
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkD3D12FenceSubmitInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_D3D12_FENCE_SUBMIT_INFO_KHR
}
#endif

extension VkDebugMarkerMarkerInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_MARKER_MARKER_INFO_EXT
}

extension VkDebugMarkerObjectNameInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_MARKER_OBJECT_NAME_INFO_EXT
}

extension VkDebugMarkerObjectTagInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_MARKER_OBJECT_TAG_INFO_EXT
}

extension VkDebugReportCallbackCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT
}

extension VkDebugUtilsLabelEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT
}

extension VkDebugUtilsMessengerCallbackDataEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CALLBACK_DATA_EXT
}

extension VkDebugUtilsMessengerCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
}

extension VkDebugUtilsObjectNameInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT
}

extension VkDebugUtilsObjectTagInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_TAG_INFO_EXT
}

extension VkDedicatedAllocationBufferCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_BUFFER_CREATE_INFO_NV
}

extension VkDedicatedAllocationImageCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_IMAGE_CREATE_INFO_NV
}

extension VkDedicatedAllocationMemoryAllocateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_MEMORY_ALLOCATE_INFO_NV
}

extension VkDependencyInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEPENDENCY_INFO_KHR
}

extension VkDescriptorPoolCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO
}

extension VkDescriptorPoolInlineUniformBlockCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_INLINE_UNIFORM_BLOCK_CREATE_INFO_EXT
}

extension VkDescriptorSetAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO
}

extension VkDescriptorSetLayoutBindingFlagsCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO
}

extension VkDescriptorSetLayoutCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO
}

extension VkDescriptorSetLayoutSupport: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_SUPPORT
}

extension VkDescriptorSetVariableDescriptorCountAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_ALLOCATE_INFO
}

extension VkDescriptorSetVariableDescriptorCountLayoutSupport: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_LAYOUT_SUPPORT
}

extension VkDescriptorUpdateTemplateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_CREATE_INFO
}

extension VkDeviceBufferMemoryRequirementsKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_BUFFER_MEMORY_REQUIREMENTS_KHR
}

extension VkDeviceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
}

extension VkDeviceDeviceMemoryReportCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_DEVICE_MEMORY_REPORT_CREATE_INFO_EXT
}

extension VkDeviceDiagnosticsConfigCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_DIAGNOSTICS_CONFIG_CREATE_INFO_NV
}

extension VkDeviceEventInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_EVENT_INFO_EXT
}

extension VkDeviceGroupBindSparseInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_BIND_SPARSE_INFO
}

extension VkDeviceGroupCommandBufferBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_COMMAND_BUFFER_BEGIN_INFO
}

extension VkDeviceGroupDeviceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_DEVICE_CREATE_INFO
}

extension VkDeviceGroupPresentCapabilitiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_CAPABILITIES_KHR
}

extension VkDeviceGroupPresentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_INFO_KHR
}

extension VkDeviceGroupRenderPassBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_RENDER_PASS_BEGIN_INFO
}

extension VkDeviceGroupSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_SUBMIT_INFO
}

extension VkDeviceGroupSwapchainCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_SWAPCHAIN_CREATE_INFO_KHR
}

extension VkDeviceImageMemoryRequirementsKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_IMAGE_MEMORY_REQUIREMENTS_KHR
}

extension VkDeviceMemoryOpaqueCaptureAddressInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_MEMORY_OPAQUE_CAPTURE_ADDRESS_INFO
}

extension VkDeviceMemoryOverallocationCreateInfoAMD: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_MEMORY_OVERALLOCATION_CREATE_INFO_AMD
}

extension VkDeviceMemoryReportCallbackDataEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_MEMORY_REPORT_CALLBACK_DATA_EXT
}

extension VkDevicePrivateDataCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_PRIVATE_DATA_CREATE_INFO_EXT
}

extension VkDeviceQueueCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
}

extension VkDeviceQueueGlobalPriorityCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_QUEUE_GLOBAL_PRIORITY_CREATE_INFO_EXT
}

extension VkDeviceQueueInfo2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DEVICE_QUEUE_INFO_2
}

extension VkDisplayEventInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_EVENT_INFO_EXT
}

extension VkDisplayModeCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_MODE_CREATE_INFO_KHR
}

extension VkDisplayModeProperties2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_MODE_PROPERTIES_2_KHR
}

extension VkDisplayNativeHdrSurfaceCapabilitiesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_NATIVE_HDR_SURFACE_CAPABILITIES_AMD
}

extension VkDisplayPlaneCapabilities2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_PLANE_CAPABILITIES_2_KHR
}

extension VkDisplayPlaneInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_PLANE_INFO_2_KHR
}

extension VkDisplayPlaneProperties2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_PLANE_PROPERTIES_2_KHR
}

extension VkDisplayPowerInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_POWER_INFO_EXT
}

extension VkDisplayPresentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_PRESENT_INFO_KHR
}

extension VkDisplayProperties2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_PROPERTIES_2_KHR
}

extension VkDisplaySurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DISPLAY_SURFACE_CREATE_INFO_KHR
}

extension VkDrmFormatModifierPropertiesList2EXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DRM_FORMAT_MODIFIER_PROPERTIES_LIST_2_EXT
}

extension VkDrmFormatModifierPropertiesListEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_DRM_FORMAT_MODIFIER_PROPERTIES_LIST_EXT
}

extension VkEventCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EVENT_CREATE_INFO
}

extension VkExportFenceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_FENCE_CREATE_INFO
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkExportFenceWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_FENCE_WIN32_HANDLE_INFO_KHR
}
#endif

extension VkExportMemoryAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO
}

extension VkExportMemoryAllocateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO_NV
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkExportMemoryWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_MEMORY_WIN32_HANDLE_INFO_KHR
}
#endif

#if VOLCANO_PLATFORM_WINDOWS
extension VkExportMemoryWin32HandleInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_MEMORY_WIN32_HANDLE_INFO_NV
}
#endif

extension VkExportSemaphoreCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkExportSemaphoreWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR
}
#endif

extension VkExternalBufferProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_BUFFER_PROPERTIES
}

extension VkExternalFenceProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_FENCE_PROPERTIES
}

#if VOLCANO_PLATFORM_ANDROID
extension VkExternalFormatANDROID: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_FORMAT_ANDROID
}
#endif

extension VkExternalImageFormatProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_IMAGE_FORMAT_PROPERTIES
}

extension VkExternalMemoryBufferCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_BUFFER_CREATE_INFO
}

extension VkExternalMemoryImageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO
}

extension VkExternalMemoryImageCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO_NV
}

extension VkExternalSemaphoreProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_PROPERTIES
}

extension VkFenceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO
}

extension VkFenceGetFdInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FENCE_GET_FD_INFO_KHR
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkFenceGetWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FENCE_GET_WIN32_HANDLE_INFO_KHR
}
#endif

extension VkFilterCubicImageViewImageFormatPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FILTER_CUBIC_IMAGE_VIEW_IMAGE_FORMAT_PROPERTIES_EXT
}

extension VkFormatProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_2
}

extension VkFormatProperties3KHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_3_KHR
}

extension VkFragmentShadingRateAttachmentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR
}

extension VkFramebufferAttachmentImageInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENT_IMAGE_INFO
}

extension VkFramebufferAttachmentsCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENTS_CREATE_INFO
}

extension VkFramebufferCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
}

extension VkFramebufferMixedSamplesCombinationNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_MIXED_SAMPLES_COMBINATION_NV
}

extension VkGeneratedCommandsInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GENERATED_COMMANDS_INFO_NV
}

extension VkGeneratedCommandsMemoryRequirementsInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GENERATED_COMMANDS_MEMORY_REQUIREMENTS_INFO_NV
}

extension VkGeometryAABBNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GEOMETRY_AABB_NV
}

extension VkGeometryNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GEOMETRY_NV
}

extension VkGeometryTrianglesNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GEOMETRY_TRIANGLES_NV
}

extension VkGraphicsPipelineCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
}

extension VkGraphicsPipelineShaderGroupsCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_SHADER_GROUPS_CREATE_INFO_NV
}

extension VkGraphicsShaderGroupCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_GRAPHICS_SHADER_GROUP_CREATE_INFO_NV
}

extension VkHdrMetadataEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_HDR_METADATA_EXT
}

extension VkHeadlessSurfaceCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_HEADLESS_SURFACE_CREATE_INFO_EXT
}

#if VOLCANO_PLATFORM_IOS
extension VkIOSSurfaceCreateInfoMVK: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK
}
#endif

extension VkImageBlit2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_BLIT_2_KHR
}

extension VkImageCopy2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_COPY_2_KHR
}

extension VkImageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO
}

extension VkImageDrmFormatModifierExplicitCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_EXPLICIT_CREATE_INFO_EXT
}

extension VkImageDrmFormatModifierListCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_LIST_CREATE_INFO_EXT
}

extension VkImageDrmFormatModifierPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_PROPERTIES_EXT
}

extension VkImageFormatListCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_FORMAT_LIST_CREATE_INFO
}

extension VkImageFormatProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_FORMAT_PROPERTIES_2
}

extension VkImageMemoryBarrier: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER
}

extension VkImageMemoryBarrier2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER_2_KHR
}

extension VkImageMemoryRequirementsInfo2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_REQUIREMENTS_INFO_2
}

extension VkImagePlaneMemoryRequirementsInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_PLANE_MEMORY_REQUIREMENTS_INFO
}

extension VkImageResolve2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_RESOLVE_2_KHR
}

extension VkImageSparseMemoryRequirementsInfo2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_SPARSE_MEMORY_REQUIREMENTS_INFO_2
}

extension VkImageStencilUsageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_STENCIL_USAGE_CREATE_INFO
}

extension VkImageSwapchainCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_SWAPCHAIN_CREATE_INFO_KHR
}

extension VkImageViewASTCDecodeModeEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_ASTC_DECODE_MODE_EXT
}

extension VkImageViewAddressPropertiesNVX: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_ADDRESS_PROPERTIES_NVX
}

extension VkImageViewCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
}

extension VkImageViewHandleInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_HANDLE_INFO_NVX
}

extension VkImageViewUsageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_USAGE_CREATE_INFO
}

#if VOLCANO_PLATFORM_ANDROID
extension VkImportAndroidHardwareBufferInfoANDROID: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_ANDROID_HARDWARE_BUFFER_INFO_ANDROID
}
#endif

extension VkImportFenceFdInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_FENCE_FD_INFO_KHR
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkImportFenceWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_FENCE_WIN32_HANDLE_INFO_KHR
}
#endif

extension VkImportMemoryFdInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_MEMORY_FD_INFO_KHR
}

extension VkImportMemoryHostPointerInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_MEMORY_HOST_POINTER_INFO_EXT
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkImportMemoryWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR
}
#endif

#if VOLCANO_PLATFORM_WINDOWS
extension VkImportMemoryWin32HandleInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_NV
}
#endif

extension VkImportSemaphoreFdInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_FD_INFO_KHR
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkImportSemaphoreWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR
}
#endif

extension VkIndirectCommandsLayoutCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_INDIRECT_COMMANDS_LAYOUT_CREATE_INFO_NV
}

extension VkIndirectCommandsLayoutTokenNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_INDIRECT_COMMANDS_LAYOUT_TOKEN_NV
}

extension VkInitializePerformanceApiInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_INITIALIZE_PERFORMANCE_API_INFO_INTEL
}

extension VkInstanceCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
}

#if VOLCANO_PLATFORM_MACOS
extension VkMacOSSurfaceCreateInfoMVK: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK
}
#endif

extension VkMappedMemoryRange: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE
}

extension VkMemoryAllocateFlagsInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO
}

extension VkMemoryAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
}

extension VkMemoryBarrier: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER
}

extension VkMemoryBarrier2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER_2_KHR
}

extension VkMemoryDedicatedAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_DEDICATED_ALLOCATE_INFO
}

extension VkMemoryDedicatedRequirements: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_DEDICATED_REQUIREMENTS
}

extension VkMemoryFdPropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_FD_PROPERTIES_KHR
}

#if VOLCANO_PLATFORM_ANDROID
extension VkMemoryGetAndroidHardwareBufferInfoANDROID: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_GET_ANDROID_HARDWARE_BUFFER_INFO_ANDROID
}
#endif

extension VkMemoryGetFdInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_GET_FD_INFO_KHR
}

extension VkMemoryGetRemoteAddressInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_GET_REMOTE_ADDRESS_INFO_NV
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkMemoryGetWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR
}
#endif

extension VkMemoryHostPointerPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_HOST_POINTER_PROPERTIES_EXT
}

extension VkMemoryOpaqueCaptureAddressAllocateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_OPAQUE_CAPTURE_ADDRESS_ALLOCATE_INFO
}

extension VkMemoryPriorityAllocateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_PRIORITY_ALLOCATE_INFO_EXT
}

extension VkMemoryRequirements2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkMemoryWin32HandlePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MEMORY_WIN32_HANDLE_PROPERTIES_KHR
}
#endif

extension VkMultisamplePropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MULTISAMPLE_PROPERTIES_EXT
}

extension VkMultiviewPerViewAttributesInfoNVX: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MULTIVIEW_PER_VIEW_ATTRIBUTES_INFO_NVX
}

extension VkMutableDescriptorTypeCreateInfoVALVE: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_MUTABLE_DESCRIPTOR_TYPE_CREATE_INFO_VALVE
}

#if VOLCANO_PLATFORM_ANDROID
extension VkNativeBufferANDROID: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_NATIVE_BUFFER_ANDROID
}
#endif

extension VkPerformanceConfigurationAcquireInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PERFORMANCE_CONFIGURATION_ACQUIRE_INFO_INTEL
}

extension VkPerformanceCounterDescriptionKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PERFORMANCE_COUNTER_DESCRIPTION_KHR
}

extension VkPerformanceCounterKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PERFORMANCE_COUNTER_KHR
}

extension VkPerformanceMarkerInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PERFORMANCE_MARKER_INFO_INTEL
}

extension VkPerformanceOverrideInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PERFORMANCE_OVERRIDE_INFO_INTEL
}

extension VkPerformanceQuerySubmitInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PERFORMANCE_QUERY_SUBMIT_INFO_KHR
}

extension VkPerformanceStreamMarkerInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PERFORMANCE_STREAM_MARKER_INFO_INTEL
}

extension VkPhysicalDevice16BitStorageFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_16BIT_STORAGE_FEATURES
}

extension VkPhysicalDevice4444FormatsFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_4444_FORMATS_FEATURES_EXT
}

extension VkPhysicalDevice8BitStorageFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_8BIT_STORAGE_FEATURES
}

extension VkPhysicalDeviceASTCDecodeFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ASTC_DECODE_FEATURES_EXT
}

extension VkPhysicalDeviceAccelerationStructureFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR
}

extension VkPhysicalDeviceAccelerationStructurePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_PROPERTIES_KHR
}

extension VkPhysicalDeviceBlendOperationAdvancedFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BLEND_OPERATION_ADVANCED_FEATURES_EXT
}

extension VkPhysicalDeviceBlendOperationAdvancedPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BLEND_OPERATION_ADVANCED_PROPERTIES_EXT
}

extension VkPhysicalDeviceBorderColorSwizzleFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BORDER_COLOR_SWIZZLE_FEATURES_EXT
}

extension VkPhysicalDeviceBufferDeviceAddressFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES
}

extension VkPhysicalDeviceBufferDeviceAddressFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES_EXT
}

extension VkPhysicalDeviceCoherentMemoryFeaturesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COHERENT_MEMORY_FEATURES_AMD
}

extension VkPhysicalDeviceColorWriteEnableFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COLOR_WRITE_ENABLE_FEATURES_EXT
}

extension VkPhysicalDeviceComputeShaderDerivativesFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COMPUTE_SHADER_DERIVATIVES_FEATURES_NV
}

extension VkPhysicalDeviceConditionalRenderingFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CONDITIONAL_RENDERING_FEATURES_EXT
}

extension VkPhysicalDeviceConservativeRasterizationPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CONSERVATIVE_RASTERIZATION_PROPERTIES_EXT
}

extension VkPhysicalDeviceCooperativeMatrixFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COOPERATIVE_MATRIX_FEATURES_NV
}

extension VkPhysicalDeviceCooperativeMatrixPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COOPERATIVE_MATRIX_PROPERTIES_NV
}

extension VkPhysicalDeviceCornerSampledImageFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CORNER_SAMPLED_IMAGE_FEATURES_NV
}

extension VkPhysicalDeviceCoverageReductionModeFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COVERAGE_REDUCTION_MODE_FEATURES_NV
}

extension VkPhysicalDeviceCustomBorderColorFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CUSTOM_BORDER_COLOR_FEATURES_EXT
}

extension VkPhysicalDeviceCustomBorderColorPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CUSTOM_BORDER_COLOR_PROPERTIES_EXT
}

extension VkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEDICATED_ALLOCATION_IMAGE_ALIASING_FEATURES_NV
}

extension VkPhysicalDeviceDepthClipEnableFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_CLIP_ENABLE_FEATURES_EXT
}

extension VkPhysicalDeviceDepthStencilResolveProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_STENCIL_RESOLVE_PROPERTIES
}

extension VkPhysicalDeviceDescriptorIndexingFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES
}

extension VkPhysicalDeviceDescriptorIndexingProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_PROPERTIES
}

extension VkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_GENERATED_COMMANDS_FEATURES_NV
}

extension VkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_GENERATED_COMMANDS_PROPERTIES_NV
}

extension VkPhysicalDeviceDeviceMemoryReportFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_MEMORY_REPORT_FEATURES_EXT
}

extension VkPhysicalDeviceDiagnosticsConfigFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DIAGNOSTICS_CONFIG_FEATURES_NV
}

extension VkPhysicalDeviceDiscardRectanglePropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DISCARD_RECTANGLE_PROPERTIES_EXT
}

extension VkPhysicalDeviceDriverProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES
}

extension VkPhysicalDeviceDrmPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRM_PROPERTIES_EXT
}

extension VkPhysicalDeviceDynamicRenderingFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DYNAMIC_RENDERING_FEATURES_KHR
}

extension VkPhysicalDeviceExclusiveScissorFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXCLUSIVE_SCISSOR_FEATURES_NV
}

extension VkPhysicalDeviceExtendedDynamicState2FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_2_FEATURES_EXT
}

extension VkPhysicalDeviceExtendedDynamicStateFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_FEATURES_EXT
}

extension VkPhysicalDeviceExternalBufferInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_BUFFER_INFO
}

extension VkPhysicalDeviceExternalFenceInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_FENCE_INFO
}

extension VkPhysicalDeviceExternalImageFormatInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_IMAGE_FORMAT_INFO
}

extension VkPhysicalDeviceExternalMemoryHostPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_MEMORY_HOST_PROPERTIES_EXT
}

extension VkPhysicalDeviceExternalMemoryRDMAFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_MEMORY_RDMA_FEATURES_NV
}

extension VkPhysicalDeviceExternalSemaphoreInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_SEMAPHORE_INFO
}

extension VkPhysicalDeviceFeatures2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2
}

extension VkPhysicalDeviceFloatControlsProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FLOAT_CONTROLS_PROPERTIES
}

extension VkPhysicalDeviceFragmentDensityMap2FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_2_FEATURES_EXT
}

extension VkPhysicalDeviceFragmentDensityMap2PropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_2_PROPERTIES_EXT
}

extension VkPhysicalDeviceFragmentDensityMapFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_FEATURES_EXT
}

extension VkPhysicalDeviceFragmentDensityMapPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_PROPERTIES_EXT
}

extension VkPhysicalDeviceFragmentShaderBarycentricFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADER_BARYCENTRIC_FEATURES_NV
}

extension VkPhysicalDeviceFragmentShaderInterlockFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADER_INTERLOCK_FEATURES_EXT
}

extension VkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_ENUMS_FEATURES_NV
}

extension VkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_ENUMS_PROPERTIES_NV
}

extension VkPhysicalDeviceFragmentShadingRateFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR
}

extension VkPhysicalDeviceFragmentShadingRateKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_KHR
}

extension VkPhysicalDeviceFragmentShadingRatePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_PROPERTIES_KHR
}

extension VkPhysicalDeviceGlobalPriorityQueryFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GLOBAL_PRIORITY_QUERY_FEATURES_EXT
}

extension VkPhysicalDeviceGroupProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GROUP_PROPERTIES
}

extension VkPhysicalDeviceHostQueryResetFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_HOST_QUERY_RESET_FEATURES
}

extension VkPhysicalDeviceIDProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES
}

extension VkPhysicalDeviceImageDrmFormatModifierInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_DRM_FORMAT_MODIFIER_INFO_EXT
}

extension VkPhysicalDeviceImageFormatInfo2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_FORMAT_INFO_2
}

extension VkPhysicalDeviceImageRobustnessFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_ROBUSTNESS_FEATURES_EXT
}

extension VkPhysicalDeviceImageViewImageFormatInfoEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_VIEW_IMAGE_FORMAT_INFO_EXT
}

extension VkPhysicalDeviceImagelessFramebufferFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGELESS_FRAMEBUFFER_FEATURES
}

extension VkPhysicalDeviceIndexTypeUint8FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INDEX_TYPE_UINT8_FEATURES_EXT
}

extension VkPhysicalDeviceInheritedViewportScissorFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INHERITED_VIEWPORT_SCISSOR_FEATURES_NV
}

extension VkPhysicalDeviceInlineUniformBlockFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INLINE_UNIFORM_BLOCK_FEATURES_EXT
}

extension VkPhysicalDeviceInlineUniformBlockPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INLINE_UNIFORM_BLOCK_PROPERTIES_EXT
}

extension VkPhysicalDeviceInvocationMaskFeaturesHUAWEI: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INVOCATION_MASK_FEATURES_HUAWEI
}

extension VkPhysicalDeviceLineRasterizationFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_LINE_RASTERIZATION_FEATURES_EXT
}

extension VkPhysicalDeviceLineRasterizationPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_LINE_RASTERIZATION_PROPERTIES_EXT
}

extension VkPhysicalDeviceMaintenance3Properties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_3_PROPERTIES
}

extension VkPhysicalDeviceMaintenance4FeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_4_FEATURES_KHR
}

extension VkPhysicalDeviceMaintenance4PropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_4_PROPERTIES_KHR
}

extension VkPhysicalDeviceMemoryBudgetPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_BUDGET_PROPERTIES_EXT
}

extension VkPhysicalDeviceMemoryPriorityFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PRIORITY_FEATURES_EXT
}

extension VkPhysicalDeviceMemoryProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PROPERTIES_2
}

extension VkPhysicalDeviceMeshShaderFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_FEATURES_NV
}

extension VkPhysicalDeviceMeshShaderPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_PROPERTIES_NV
}

extension VkPhysicalDeviceMultiDrawFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTI_DRAW_FEATURES_EXT
}

extension VkPhysicalDeviceMultiDrawPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTI_DRAW_PROPERTIES_EXT
}

extension VkPhysicalDeviceMultiviewFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_FEATURES
}

extension VkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_PER_VIEW_ATTRIBUTES_PROPERTIES_NVX
}

extension VkPhysicalDeviceMultiviewProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_PROPERTIES
}

extension VkPhysicalDeviceMutableDescriptorTypeFeaturesVALVE: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MUTABLE_DESCRIPTOR_TYPE_FEATURES_VALVE
}

extension VkPhysicalDevicePCIBusInfoPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PCI_BUS_INFO_PROPERTIES_EXT
}

extension VkPhysicalDevicePageableDeviceLocalMemoryFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PAGEABLE_DEVICE_LOCAL_MEMORY_FEATURES_EXT
}

extension VkPhysicalDevicePerformanceQueryFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PERFORMANCE_QUERY_FEATURES_KHR
}

extension VkPhysicalDevicePerformanceQueryPropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PERFORMANCE_QUERY_PROPERTIES_KHR
}

extension VkPhysicalDevicePipelineCreationCacheControlFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PIPELINE_CREATION_CACHE_CONTROL_FEATURES_EXT
}

extension VkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PIPELINE_EXECUTABLE_PROPERTIES_FEATURES_KHR
}

extension VkPhysicalDevicePointClippingProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_POINT_CLIPPING_PROPERTIES
}

extension VkPhysicalDevicePresentIdFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENT_ID_FEATURES_KHR
}

extension VkPhysicalDevicePresentWaitFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENT_WAIT_FEATURES_KHR
}

#if VOLCANO_PLATFORM_ANDROID
extension VkPhysicalDevicePresentationPropertiesANDROID: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENTATION_PROPERTIES_ANDROID
}
#endif

extension VkPhysicalDevicePrimitiveTopologyListRestartFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRIMITIVE_TOPOLOGY_LIST_RESTART_FEATURES_EXT
}

extension VkPhysicalDevicePrivateDataFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRIVATE_DATA_FEATURES_EXT
}

extension VkPhysicalDeviceProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2
}

extension VkPhysicalDeviceProtectedMemoryFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROTECTED_MEMORY_FEATURES
}

extension VkPhysicalDeviceProtectedMemoryProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROTECTED_MEMORY_PROPERTIES
}

extension VkPhysicalDeviceProvokingVertexFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROVOKING_VERTEX_FEATURES_EXT
}

extension VkPhysicalDeviceProvokingVertexPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROVOKING_VERTEX_PROPERTIES_EXT
}

extension VkPhysicalDevicePushDescriptorPropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PUSH_DESCRIPTOR_PROPERTIES_KHR
}

extension VkPhysicalDeviceRGBA10X6FormatsFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RGBA10X6_FORMATS_FEATURES_EXT
}

extension VkPhysicalDeviceRayQueryFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR
}

extension VkPhysicalDeviceRayTracingMotionBlurFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_MOTION_BLUR_FEATURES_NV
}

extension VkPhysicalDeviceRayTracingPipelineFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR
}

extension VkPhysicalDeviceRayTracingPipelinePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_PROPERTIES_KHR
}

extension VkPhysicalDeviceRayTracingPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PROPERTIES_NV
}

extension VkPhysicalDeviceRepresentativeFragmentTestFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_REPRESENTATIVE_FRAGMENT_TEST_FEATURES_NV
}

extension VkPhysicalDeviceRobustness2FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ROBUSTNESS_2_FEATURES_EXT
}

extension VkPhysicalDeviceRobustness2PropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ROBUSTNESS_2_PROPERTIES_EXT
}

extension VkPhysicalDeviceSampleLocationsPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLE_LOCATIONS_PROPERTIES_EXT
}

extension VkPhysicalDeviceSamplerFilterMinmaxProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_FILTER_MINMAX_PROPERTIES
}

extension VkPhysicalDeviceSamplerYcbcrConversionFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_YCBCR_CONVERSION_FEATURES
}

extension VkPhysicalDeviceScalarBlockLayoutFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SCALAR_BLOCK_LAYOUT_FEATURES
}

extension VkPhysicalDeviceSeparateDepthStencilLayoutsFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SEPARATE_DEPTH_STENCIL_LAYOUTS_FEATURES
}

extension VkPhysicalDeviceShaderAtomicFloat2FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_FLOAT_2_FEATURES_EXT
}

extension VkPhysicalDeviceShaderAtomicFloatFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_FLOAT_FEATURES_EXT
}

extension VkPhysicalDeviceShaderAtomicInt64Features: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_INT64_FEATURES
}

extension VkPhysicalDeviceShaderClockFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CLOCK_FEATURES_KHR
}

extension VkPhysicalDeviceShaderCoreProperties2AMD: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CORE_PROPERTIES_2_AMD
}

extension VkPhysicalDeviceShaderCorePropertiesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CORE_PROPERTIES_AMD
}

extension VkPhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DEMOTE_TO_HELPER_INVOCATION_FEATURES_EXT
}

extension VkPhysicalDeviceShaderDrawParametersFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DRAW_PARAMETERS_FEATURES
}

extension VkPhysicalDeviceShaderFloat16Int8Features: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_FLOAT16_INT8_FEATURES
}

extension VkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_IMAGE_ATOMIC_INT64_FEATURES_EXT
}

extension VkPhysicalDeviceShaderImageFootprintFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_IMAGE_FOOTPRINT_FEATURES_NV
}

extension VkPhysicalDeviceShaderIntegerDotProductFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_INTEGER_DOT_PRODUCT_FEATURES_KHR
}

extension VkPhysicalDeviceShaderIntegerDotProductPropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_INTEGER_DOT_PRODUCT_PROPERTIES_KHR
}

extension VkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_INTEGER_FUNCTIONS_2_FEATURES_INTEL
}

extension VkPhysicalDeviceShaderSMBuiltinsFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SM_BUILTINS_FEATURES_NV
}

extension VkPhysicalDeviceShaderSMBuiltinsPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SM_BUILTINS_PROPERTIES_NV
}

extension VkPhysicalDeviceShaderSubgroupExtendedTypesFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SUBGROUP_EXTENDED_TYPES_FEATURES
}

extension VkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SUBGROUP_UNIFORM_CONTROL_FLOW_FEATURES_KHR
}

extension VkPhysicalDeviceShaderTerminateInvocationFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_TERMINATE_INVOCATION_FEATURES_KHR
}

extension VkPhysicalDeviceShadingRateImageFeaturesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADING_RATE_IMAGE_FEATURES_NV
}

extension VkPhysicalDeviceShadingRateImagePropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADING_RATE_IMAGE_PROPERTIES_NV
}

extension VkPhysicalDeviceSparseImageFormatInfo2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SPARSE_IMAGE_FORMAT_INFO_2
}

extension VkPhysicalDeviceSubgroupProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_PROPERTIES
}

extension VkPhysicalDeviceSubgroupSizeControlFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_SIZE_CONTROL_FEATURES_EXT
}

extension VkPhysicalDeviceSubgroupSizeControlPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_SIZE_CONTROL_PROPERTIES_EXT
}

extension VkPhysicalDeviceSubpassShadingFeaturesHUAWEI: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBPASS_SHADING_FEATURES_HUAWEI
}

extension VkPhysicalDeviceSubpassShadingPropertiesHUAWEI: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBPASS_SHADING_PROPERTIES_HUAWEI
}

extension VkPhysicalDeviceSurfaceInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SURFACE_INFO_2_KHR
}

extension VkPhysicalDeviceSynchronization2FeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES_KHR
}

extension VkPhysicalDeviceTexelBufferAlignmentFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXEL_BUFFER_ALIGNMENT_FEATURES_EXT
}

extension VkPhysicalDeviceTexelBufferAlignmentPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXEL_BUFFER_ALIGNMENT_PROPERTIES_EXT
}

extension VkPhysicalDeviceTextureCompressionASTCHDRFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXTURE_COMPRESSION_ASTC_HDR_FEATURES_EXT
}

extension VkPhysicalDeviceTimelineSemaphoreFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES
}

extension VkPhysicalDeviceTimelineSemaphoreProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_PROPERTIES
}

extension VkPhysicalDeviceToolPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TOOL_PROPERTIES_EXT
}

extension VkPhysicalDeviceTransformFeedbackFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TRANSFORM_FEEDBACK_FEATURES_EXT
}

extension VkPhysicalDeviceTransformFeedbackPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TRANSFORM_FEEDBACK_PROPERTIES_EXT
}

extension VkPhysicalDeviceUniformBufferStandardLayoutFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_UNIFORM_BUFFER_STANDARD_LAYOUT_FEATURES
}

extension VkPhysicalDeviceVariablePointersFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VARIABLE_POINTERS_FEATURES
}

extension VkPhysicalDeviceVertexAttributeDivisorFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_ATTRIBUTE_DIVISOR_FEATURES_EXT
}

extension VkPhysicalDeviceVertexAttributeDivisorPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_ATTRIBUTE_DIVISOR_PROPERTIES_EXT
}

extension VkPhysicalDeviceVertexInputDynamicStateFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_INPUT_DYNAMIC_STATE_FEATURES_EXT
}

extension VkPhysicalDeviceVulkan11Features: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES
}

extension VkPhysicalDeviceVulkan11Properties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_PROPERTIES
}

extension VkPhysicalDeviceVulkan12Features: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES
}

extension VkPhysicalDeviceVulkan12Properties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_PROPERTIES
}

extension VkPhysicalDeviceVulkanMemoryModelFeatures: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_MEMORY_MODEL_FEATURES
}

extension VkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_WORKGROUP_MEMORY_EXPLICIT_LAYOUT_FEATURES_KHR
}

extension VkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_YCBCR_2_PLANE_444_FORMATS_FEATURES_EXT
}

extension VkPhysicalDeviceYcbcrImageArraysFeaturesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_YCBCR_IMAGE_ARRAYS_FEATURES_EXT
}

extension VkPhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ZERO_INITIALIZE_WORKGROUP_MEMORY_FEATURES_KHR
}

extension VkPipelineCacheCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO
}

extension VkPipelineColorBlendAdvancedStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_ADVANCED_STATE_CREATE_INFO_EXT
}

extension VkPipelineColorBlendStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
}

extension VkPipelineColorWriteCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_COLOR_WRITE_CREATE_INFO_EXT
}

extension VkPipelineCompilerControlCreateInfoAMD: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_COMPILER_CONTROL_CREATE_INFO_AMD
}

extension VkPipelineCoverageModulationStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_MODULATION_STATE_CREATE_INFO_NV
}

extension VkPipelineCoverageReductionStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_REDUCTION_STATE_CREATE_INFO_NV
}

extension VkPipelineCoverageToColorStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_TO_COLOR_STATE_CREATE_INFO_NV
}

extension VkPipelineCreationFeedbackCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_CREATION_FEEDBACK_CREATE_INFO_EXT
}

extension VkPipelineDepthStencilStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO
}

extension VkPipelineDiscardRectangleStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_DISCARD_RECTANGLE_STATE_CREATE_INFO_EXT
}

extension VkPipelineDynamicStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
}

extension VkPipelineExecutableInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_INFO_KHR
}

extension VkPipelineExecutableInternalRepresentationKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_INTERNAL_REPRESENTATION_KHR
}

extension VkPipelineExecutablePropertiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_PROPERTIES_KHR
}

extension VkPipelineExecutableStatisticKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_STATISTIC_KHR
}

extension VkPipelineFragmentShadingRateEnumStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_ENUM_STATE_CREATE_INFO_NV
}

extension VkPipelineFragmentShadingRateStateCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_STATE_CREATE_INFO_KHR
}

extension VkPipelineInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_INFO_KHR
}

extension VkPipelineInputAssemblyStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
}

extension VkPipelineLayoutCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
}

extension VkPipelineLibraryCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_LIBRARY_CREATE_INFO_KHR
}

extension VkPipelineMultisampleStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
}

extension VkPipelineRasterizationConservativeStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_CONSERVATIVE_STATE_CREATE_INFO_EXT
}

extension VkPipelineRasterizationDepthClipStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_DEPTH_CLIP_STATE_CREATE_INFO_EXT
}

extension VkPipelineRasterizationLineStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_LINE_STATE_CREATE_INFO_EXT
}

extension VkPipelineRasterizationProvokingVertexStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_PROVOKING_VERTEX_STATE_CREATE_INFO_EXT
}

extension VkPipelineRasterizationStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
}

extension VkPipelineRasterizationStateRasterizationOrderAMD: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_RASTERIZATION_ORDER_AMD
}

extension VkPipelineRasterizationStateStreamCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_STREAM_CREATE_INFO_EXT
}

extension VkPipelineRenderingCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO_KHR
}

extension VkPipelineRepresentativeFragmentTestStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_REPRESENTATIVE_FRAGMENT_TEST_STATE_CREATE_INFO_NV
}

extension VkPipelineSampleLocationsStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_SAMPLE_LOCATIONS_STATE_CREATE_INFO_EXT
}

extension VkPipelineShaderStageCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
}

extension VkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_REQUIRED_SUBGROUP_SIZE_CREATE_INFO_EXT
}

extension VkPipelineTessellationDomainOriginStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_DOMAIN_ORIGIN_STATE_CREATE_INFO
}

extension VkPipelineTessellationStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO
}

extension VkPipelineVertexInputDivisorStateCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_DIVISOR_STATE_CREATE_INFO_EXT
}

extension VkPipelineVertexInputStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
}

extension VkPipelineViewportCoarseSampleOrderStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_COARSE_SAMPLE_ORDER_STATE_CREATE_INFO_NV
}

extension VkPipelineViewportExclusiveScissorStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_EXCLUSIVE_SCISSOR_STATE_CREATE_INFO_NV
}

extension VkPipelineViewportShadingRateImageStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SHADING_RATE_IMAGE_STATE_CREATE_INFO_NV
}

extension VkPipelineViewportStateCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
}

extension VkPipelineViewportSwizzleStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SWIZZLE_STATE_CREATE_INFO_NV
}

extension VkPipelineViewportWScalingStateCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_W_SCALING_STATE_CREATE_INFO_NV
}

extension VkPresentIdKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PRESENT_ID_KHR
}

extension VkPresentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
}

extension VkPresentRegionsKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PRESENT_REGIONS_KHR
}

extension VkPresentTimesInfoGOOGLE: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PRESENT_TIMES_INFO_GOOGLE
}

extension VkPrivateDataSlotCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PRIVATE_DATA_SLOT_CREATE_INFO_EXT
}

extension VkProtectedSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_PROTECTED_SUBMIT_INFO
}

extension VkQueryPoolCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO
}

extension VkQueryPoolPerformanceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_QUERY_POOL_PERFORMANCE_CREATE_INFO_KHR
}

extension VkQueryPoolPerformanceQueryCreateInfoINTEL: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_QUERY_POOL_PERFORMANCE_QUERY_CREATE_INFO_INTEL
}

extension VkQueueFamilyCheckpointProperties2NV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_QUEUE_FAMILY_CHECKPOINT_PROPERTIES_2_NV
}

extension VkQueueFamilyCheckpointPropertiesNV: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_QUEUE_FAMILY_CHECKPOINT_PROPERTIES_NV
}

extension VkQueueFamilyGlobalPriorityPropertiesEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_QUEUE_FAMILY_GLOBAL_PRIORITY_PROPERTIES_EXT
}

extension VkQueueFamilyProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_QUEUE_FAMILY_PROPERTIES_2
}

extension VkRayTracingPipelineCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR
}

extension VkRayTracingPipelineCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_NV
}

extension VkRayTracingPipelineInterfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_INTERFACE_CREATE_INFO_KHR
}

extension VkRayTracingShaderGroupCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR
}

extension VkRayTracingShaderGroupCreateInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV
}

extension VkRenderPassAttachmentBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_ATTACHMENT_BEGIN_INFO
}

extension VkRenderPassBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO
}

extension VkRenderPassCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO
}

extension VkRenderPassCreateInfo2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2
}

extension VkRenderPassFragmentDensityMapCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_FRAGMENT_DENSITY_MAP_CREATE_INFO_EXT
}

extension VkRenderPassInputAttachmentAspectCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_INPUT_ATTACHMENT_ASPECT_CREATE_INFO
}

extension VkRenderPassMultiviewCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO
}

extension VkRenderPassSampleLocationsBeginInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_SAMPLE_LOCATIONS_BEGIN_INFO_EXT
}

extension VkRenderPassTransformBeginInfoQCOM: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDER_PASS_TRANSFORM_BEGIN_INFO_QCOM
}

extension VkRenderingAttachmentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO_KHR
}

extension VkRenderingFragmentDensityMapAttachmentInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_INFO_EXT
}

extension VkRenderingFragmentShadingRateAttachmentInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR
}

extension VkRenderingInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RENDERING_INFO_KHR
}

extension VkResolveImageInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_RESOLVE_IMAGE_INFO_2_KHR
}

extension VkSampleLocationsInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLE_LOCATIONS_INFO_EXT
}

extension VkSamplerBorderColorComponentMappingCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLER_BORDER_COLOR_COMPONENT_MAPPING_CREATE_INFO_EXT
}

extension VkSamplerCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO
}

extension VkSamplerCustomBorderColorCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLER_CUSTOM_BORDER_COLOR_CREATE_INFO_EXT
}

extension VkSamplerReductionModeCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLER_REDUCTION_MODE_CREATE_INFO
}

extension VkSamplerYcbcrConversionCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_CREATE_INFO
}

extension VkSamplerYcbcrConversionImageFormatProperties: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_IMAGE_FORMAT_PROPERTIES
}

extension VkSamplerYcbcrConversionInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_INFO
}

extension VkSemaphoreCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO
}

extension VkSemaphoreGetFdInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SEMAPHORE_GET_FD_INFO_KHR
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkSemaphoreGetWin32HandleInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SEMAPHORE_GET_WIN32_HANDLE_INFO_KHR
}
#endif

extension VkSemaphoreSignalInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO
}

extension VkSemaphoreSubmitInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SEMAPHORE_SUBMIT_INFO_KHR
}

extension VkSemaphoreTypeCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO
}

extension VkSemaphoreWaitInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SEMAPHORE_WAIT_INFO
}

extension VkShaderModuleCreateInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
}

extension VkShaderModuleValidationCacheCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SHADER_MODULE_VALIDATION_CACHE_CREATE_INFO_EXT
}

extension VkSharedPresentSurfaceCapabilitiesKHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SHARED_PRESENT_SURFACE_CAPABILITIES_KHR
}

extension VkSparseImageFormatProperties2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SPARSE_IMAGE_FORMAT_PROPERTIES_2
}

extension VkSparseImageMemoryRequirements2: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SPARSE_IMAGE_MEMORY_REQUIREMENTS_2
}

extension VkSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBMIT_INFO
}

extension VkSubmitInfo2KHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBMIT_INFO_2_KHR
}

extension VkSubpassBeginInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBPASS_BEGIN_INFO
}

extension VkSubpassDependency2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2
}

extension VkSubpassDescription2: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2
}

extension VkSubpassDescriptionDepthStencilResolve: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_DEPTH_STENCIL_RESOLVE
}

extension VkSubpassEndInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBPASS_END_INFO
}

extension VkSubpassShadingPipelineCreateInfoHUAWEI: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SUBPASS_SHADING_PIPELINE_CREATE_INFO_HUAWEI
}

extension VkSurfaceCapabilities2EXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_2_EXT
}

extension VkSurfaceCapabilities2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_2_KHR
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkSurfaceCapabilitiesFullScreenExclusiveEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_FULL_SCREEN_EXCLUSIVE_EXT
}
#endif

extension VkSurfaceFormat2KHR: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SURFACE_FORMAT_2_KHR
}

#if VOLCANO_PLATFORM_WINDOWS
extension VkSurfaceFullScreenExclusiveInfoEXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SURFACE_FULL_SCREEN_EXCLUSIVE_INFO_EXT
}
#endif

#if VOLCANO_PLATFORM_WINDOWS
extension VkSurfaceFullScreenExclusiveWin32InfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SURFACE_FULL_SCREEN_EXCLUSIVE_WIN32_INFO_EXT
}
#endif

extension VkSurfaceProtectedCapabilitiesKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SURFACE_PROTECTED_CAPABILITIES_KHR
}

extension VkSwapchainCounterCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SWAPCHAIN_COUNTER_CREATE_INFO_EXT
}

extension VkSwapchainCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
}

extension VkSwapchainDisplayNativeHdrCreateInfoAMD: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SWAPCHAIN_DISPLAY_NATIVE_HDR_CREATE_INFO_AMD
}

#if VOLCANO_PLATFORM_ANDROID
extension VkSwapchainImageCreateInfoANDROID: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_SWAPCHAIN_IMAGE_CREATE_INFO_ANDROID
}
#endif

extension VkTextureLODGatherFormatPropertiesAMD: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_TEXTURE_LOD_GATHER_FORMAT_PROPERTIES_AMD
}

extension VkTimelineSemaphoreSubmitInfo: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO
}

extension VkValidationCacheCreateInfoEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_VALIDATION_CACHE_CREATE_INFO_EXT
}

extension VkValidationFeaturesEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_VALIDATION_FEATURES_EXT
}

extension VkValidationFlagsEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_VALIDATION_FLAGS_EXT
}

extension VkVertexInputAttributeDescription2EXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_VERTEX_INPUT_ATTRIBUTE_DESCRIPTION_2_EXT
}

extension VkVertexInputBindingDescription2EXT: VulkanOutStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_VERTEX_INPUT_BINDING_DESCRIPTION_2_EXT
}

#if VOLCANO_PLATFORM_LINUX
extension VkWaylandSurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR
}
#endif

#if VOLCANO_PLATFORM_WINDOWS
extension VkWin32KeyedMutexAcquireReleaseInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WIN32_KEYED_MUTEX_ACQUIRE_RELEASE_INFO_KHR
}
#endif

#if VOLCANO_PLATFORM_WINDOWS
extension VkWin32KeyedMutexAcquireReleaseInfoNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WIN32_KEYED_MUTEX_ACQUIRE_RELEASE_INFO_NV
}
#endif

#if VOLCANO_PLATFORM_WINDOWS
extension VkWin32SurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR
}
#endif

extension VkWriteDescriptorSet: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET
}

extension VkWriteDescriptorSetAccelerationStructureKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_KHR
}

extension VkWriteDescriptorSetAccelerationStructureNV: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_NV
}

extension VkWriteDescriptorSetInlineUniformBlockEXT: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_INLINE_UNIFORM_BLOCK_EXT
}

#if VOLCANO_PLATFORM_LINUX
extension VkXcbSurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR
}
#endif

#if VOLCANO_PLATFORM_LINUX
extension VkXlibSurfaceCreateInfoKHR: VulkanInStructure {
    public static let type: VkStructureType = .VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR
}
#endif