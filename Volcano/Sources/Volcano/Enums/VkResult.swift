//
//  VkResult.swift
//  Volcano
//
//  Created by Serhii Mumriak on 11.01.2021.
//

import CVulkan

public typealias VkResult = CVulkan.VkResult

public extension VkResult {
    static let success: VkResult = .VK_SUCCESS
    static let notReady: VkResult = .VK_NOT_READY
    static let timeout: VkResult = .VK_TIMEOUT
    static let eventSet: VkResult = .VK_EVENT_SET
    static let eventReset: VkResult = .VK_EVENT_RESET
    static let iorOutOfHostMemory: VkResult = .VK_ERROR_OUT_OF_HOST_MEMORY
    static let errorOutOfDeviceMemory: VkResult = .VK_ERROR_OUT_OF_DEVICE_MEMORY
    static let errorInitializationFailed: VkResult = .VK_ERROR_INITIALIZATION_FAILED
    static let errorDeviceLost: VkResult = .VK_ERROR_DEVICE_LOST
    static let errorMemoryMapFailed: VkResult = .VK_ERROR_MEMORY_MAP_FAILED
    static let errorLayerNotPresent: VkResult = .VK_ERROR_LAYER_NOT_PRESENT
    static let errorExtensionNotPresent: VkResult = .VK_ERROR_EXTENSION_NOT_PRESENT
    static let errorFeatureNotPresent: VkResult = .VK_ERROR_FEATURE_NOT_PRESENT
    static let errorIncompatibleDriver: VkResult = .VK_ERROR_INCOMPATIBLE_DRIVER
    static let errorTooManyObjects: VkResult = .VK_ERROR_TOO_MANY_OBJECTS
    static let errorFormatNotSupported: VkResult = .VK_ERROR_FORMAT_NOT_SUPPORTED
    static let errorFragncomplete: VkResult = .VK_INCOMPLETE
    static let errmentedPool: VkResult = .VK_ERROR_FRAGMENTED_POOL
    static let errorUnknown: VkResult = .VK_ERROR_UNKNOWN
    static let errorOutOfPoolMemory: VkResult = .VK_ERROR_OUT_OF_POOL_MEMORY
    static let errorInvalidExternalHandle: VkResult = .VK_ERROR_INVALID_EXTERNAL_HANDLE
    static let errorFragmentation: VkResult = .VK_ERROR_FRAGMENTATION
    static let errorInvalidOpaqueCaptureAddress: VkResult = .VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS
    static let errorSurfaceLost: VkResult = .VK_ERROR_SURFACE_LOST_KHR
    static let errorNativeWindowInUse: VkResult = .VK_ERROR_NATIVE_WINDOW_IN_USE_KHR
    static let suboptimal: VkResult = .VK_SUBOPTIMAL_KHR
    static let errorOutOfDate: VkResult = .VK_ERROR_OUT_OF_DATE_KHR
    static let errorIncompatibleDisplay: VkResult = .VK_ERROR_INCOMPATIBLE_DISPLAY_KHR
    static let errorValidationFailedEXT: VkResult = .VK_ERROR_VALIDATION_FAILED_EXT
    static let errorInvalidShaderNV: VkResult = .VK_ERROR_INVALID_SHADER_NV
    static let errorInvalidDrmFormatModifierPlaneLayoutEXT: VkResult = .VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT
    static let errorNotPermittedEXT: VkResult = .VK_ERROR_NOT_PERMITTED_EXT
    static let errorFullScreenExclusiveModeLostEXT: VkResult = .VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT
    static let threadIdle: VkResult = .VK_THREAD_IDLE_KHR
    static let threadDone: VkResult = .VK_THREAD_DONE_KHR
    static let operationDeferred: VkResult = .VK_OPERATION_DEFERRED_KHR
    static let operationNotDeferred: VkResult = .VK_OPERATION_NOT_DEFERRED_KHR
    static let pipelineCompileRequiredEXT: VkResult = .VK_PIPELINE_COMPILE_REQUIRED_EXT
}
