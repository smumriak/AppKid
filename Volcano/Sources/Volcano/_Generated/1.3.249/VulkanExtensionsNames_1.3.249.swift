// WARNING: DO NOT MODIFY
// This file is generated by vkthings tool
// #*# Metadata version: 1
// #*# Date generated: '2023-10-20 02:16:10Z'
// #*# Vulkan Version: 1.3.249
//
//  VulkanExtensionsNames.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.07.2021.
//

#if VULKAN_VERSION_1_3_249

    import Foundation
    import TinyFoundation

    public enum InstanceExtension: String {
        case acquireDrmDisplayExt = "VK_EXT_acquire_drm_display"
        case acquireXlibDisplayExt = "VK_EXT_acquire_xlib_display"
        case androidSurfaceKhr = "VK_KHR_android_surface"
        case applicationParametersExt = "VK_EXT_application_parameters"
        case debugUtilsExt = "VK_EXT_debug_utils"
        case deviceGroupCreationKhr = "VK_KHR_device_group_creation"
        case directDriverLoadingLunarg = "VK_LUNARG_direct_driver_loading"
        case directModeDisplayExt = "VK_EXT_direct_mode_display"
        case directfbSurfaceExt = "VK_EXT_directfb_surface"
        case displayKhr = "VK_KHR_display"
        case displaySurfaceCounterExt = "VK_EXT_display_surface_counter"
        case extension384Ext = "VK_EXT_extension_384"
        case extension385Mesa = "VK_MESA_extension_385"
        case extension504Nv = "VK_NV_extension_504"
        case externalFenceCapabilitiesKhr = "VK_KHR_external_fence_capabilities"
        case externalMemoryCapabilitiesKhr = "VK_KHR_external_memory_capabilities"
        case externalSemaphoreCapabilitiesKhr = "VK_KHR_external_semaphore_capabilities"
        case getDisplayProperties2Khr = "VK_KHR_get_display_properties2"
        case getPhysicalDeviceProperties2Khr = "VK_KHR_get_physical_device_properties2"
        case getSurfaceCapabilities2Khr = "VK_KHR_get_surface_capabilities2"
        case headlessSurfaceExt = "VK_EXT_headless_surface"
        case imagepipeSurfaceFuchsia = "VK_FUCHSIA_imagepipe_surface"
        case metalSurfaceExt = "VK_EXT_metal_surface"
        case mirSurfaceKhr = "VK_KHR_mir_surface"
        case moltenvkMvk = "VK_MVK_moltenvk"
        case portabilityEnumerationKhr = "VK_KHR_portability_enumeration"
        case screenSurfaceQnx = "VK_QNX_screen_surface"
        case streamDescriptorSurfaceGgp = "VK_GGP_stream_descriptor_surface"
        case surfaceKhr = "VK_KHR_surface"
        case surfaceMaintenance1Ext = "VK_EXT_surface_maintenance1"
        case surfaceProtectedCapabilitiesKhr = "VK_KHR_surface_protected_capabilities"
        case surfacelessQueryGoogle = "VK_GOOGLE_surfaceless_query"
        case swapchainColorspaceExt = "VK_EXT_swapchain_colorspace"
        case validationFeaturesExt = "VK_EXT_validation_features"
        case viSurfaceNn = "VK_NN_vi_surface"
        case waylandSurfaceKhr = "VK_KHR_wayland_surface"
        case win32SurfaceKhr = "VK_KHR_win32_surface"
        case xcbSurfaceKhr = "VK_KHR_xcb_surface"
        case xlibSurfaceKhr = "VK_KHR_xlib_surface"
    }

    public enum DeviceExtension: String {
        case accelerationStructureKhr = "VK_KHR_acceleration_structure"
        case acquireWinrtDisplayNv = "VK_NV_acquire_winrt_display"
        case amigoProfilingSec = "VK_SEC_amigo_profiling"
        case astcDecodeModeExt = "VK_EXT_astc_decode_mode"
        case attachmentFeedbackLoopLayoutExt = "VK_EXT_attachment_feedback_loop_layout"
        case binaryImportNvx = "VK_NVX_binary_import"
        case bindMemory2Khr = "VK_KHR_bind_memory2"
        case blendOperationAdvancedExt = "VK_EXT_blend_operation_advanced"
        case borderColorSwizzleExt = "VK_EXT_border_color_swizzle"
        case bufferCollectionFuchsia = "VK_FUCHSIA_buffer_collection"
        case bufferDeviceAddressKhr = "VK_KHR_buffer_device_address"
        case bufferMarkerAmd = "VK_AMD_buffer_marker"
        case calibratedTimestampsExt = "VK_EXT_calibrated_timestamps"
        case clipSpaceWScalingNv = "VK_NV_clip_space_w_scaling"
        case clusterCullingShaderHuawei = "VK_HUAWEI_cluster_culling_shader"
        case colorWriteEnableExt = "VK_EXT_color_write_enable"
        case computeShaderDerivativesNv = "VK_NV_compute_shader_derivatives"
        case conditionalRenderingExt = "VK_EXT_conditional_rendering"
        case conservativeRasterizationExt = "VK_EXT_conservative_rasterization"
        case cooperativeMatrixNv = "VK_NV_cooperative_matrix"
        case copyCommands2Khr = "VK_KHR_copy_commands2"
        case copyMemoryIndirectNv = "VK_NV_copy_memory_indirect"
        case cornerSampledImageNv = "VK_NV_corner_sampled_image"
        case coverageReductionModeNv = "VK_NV_coverage_reduction_mode"
        case createRenderpass2Khr = "VK_KHR_create_renderpass2"
        case customBorderColorExt = "VK_EXT_custom_border_color"
        case debugMarkerExt = "VK_EXT_debug_marker"
        case decorateStringGoogle = "VK_GOOGLE_decorate_string"
        case dedicatedAllocationImageAliasingNv = "VK_NV_dedicated_allocation_image_aliasing"
        case dedicatedAllocationKhr = "VK_KHR_dedicated_allocation"
        case deferredHostOperationsKhr = "VK_KHR_deferred_host_operations"
        case depthClampZeroOneExt = "VK_EXT_depth_clamp_zero_one"
        case depthClipControlExt = "VK_EXT_depth_clip_control"
        case depthClipEnableExt = "VK_EXT_depth_clip_enable"
        case depthRangeUnrestrictedExt = "VK_EXT_depth_range_unrestricted"
        case depthStencilResolveKhr = "VK_KHR_depth_stencil_resolve"
        case descriptorBufferExt = "VK_EXT_descriptor_buffer"
        case descriptorIndexingExt = "VK_EXT_descriptor_indexing"
        case descriptorSetHostMappingValve = "VK_VALVE_descriptor_set_host_mapping"
        case descriptorUpdateTemplateKhr = "VK_KHR_descriptor_update_template"
        case deviceAddressBindingReportExt = "VK_EXT_device_address_binding_report"
        case deviceCoherentMemoryAmd = "VK_AMD_device_coherent_memory"
        case deviceDiagnosticCheckpointsNv = "VK_NV_device_diagnostic_checkpoints"
        case deviceDiagnosticsConfigNv = "VK_NV_device_diagnostics_config"
        case deviceFaultExt = "VK_EXT_device_fault"
        case deviceGeneratedCommandsNv = "VK_NV_device_generated_commands"
        case deviceGeneratedCommandsNvx = "VK_NVX_device_generated_commands"
        case deviceGroupKhr = "VK_KHR_device_group"
        case deviceMemoryReportExt = "VK_EXT_device_memory_report"
        case discardRectanglesExt = "VK_EXT_discard_rectangles"
        case displacementMicromapNv = "VK_NV_displacement_micromap"
        case displayControlExt = "VK_EXT_display_control"
        case displayNativeHdrAmd = "VK_AMD_display_native_hdr"
        case displaySwapchainKhr = "VK_KHR_display_swapchain"
        case displayTimingGoogle = "VK_GOOGLE_display_timing"
        case drawIndirectCountAmd = "VK_AMD_draw_indirect_count"
        case drawIndirectCountKhr = "VK_KHR_draw_indirect_count"
        case driverPropertiesKhr = "VK_KHR_driver_properties"
        case dynamicRenderingKhr = "VK_KHR_dynamic_rendering"
        case eightbitStorageKhr = "VK_KHR_8bit_storage"
        case extendedDynamicState2Ext = "VK_EXT_extended_dynamic_state2"
        case extendedDynamicState3Ext = "VK_EXT_extended_dynamic_state3"
        case extendedDynamicStateExt = "VK_EXT_extended_dynamic_state"
        case extension209Khr = "VK_KHR_extension_209"
        case extension267Ext = "VK_EXT_extension_267"
        case extension271Intel = "VK_INTEL_extension_271"
        case extension273Intel = "VK_INTEL_extension_273"
        case extension280Khr = "VK_KHR_extension_280"
        case extension284Ext = "VK_EXT_extension_284"
        case extension299Khr = "VK_KHR_extension_299"
        case extension308Nv = "VK_NV_extension_308"
        case extension335Khr = "VK_KHR_extension_335"
        case extension350Khr = "VK_KHR_extension_350"
        case extension420Ext = "VK_EXT_extension_420"
        case extension469Android = "VK_ANDROID_extension_469"
        case extension496Ext = "VK_EXT_extension_496"
        case extension497Ext = "VK_EXT_extension_497"
        case extension500Ext = "VK_EXT_extension_500"
        case extension501Ext = "VK_EXT_extension_501"
        case extension502Ext = "VK_EXT_extension_502"
        case extension503Ext = "VK_EXT_extension_503"
        case extension505Ext = "VK_EXT_extension_505"
        case extension506Nv = "VK_NV_extension_506"
        case extension507Khr = "VK_KHR_extension_507"
        case extension508Ext = "VK_EXT_extension_508"
        case extension509Ext = "VK_EXT_extension_509"
        case extension510Mesa = "VK_MESA_extension_510"
        case extension512Ext = "VK_EXT_extension_512"
        case extension513Khr = "VK_KHR_extension_513"
        case extension514Khr = "VK_KHR_extension_514"
        case extension515Khr = "VK_KHR_extension_515"
        case extension516Khr = "VK_KHR_extension_516"
        case extension518Mesa = "VK_MESA_extension_518"
        case extension519Qcom = "VK_QCOM_extension_519"
        case extension520Qcom = "VK_QCOM_extension_520"
        case extension521Qcom = "VK_QCOM_extension_521"
        case extension522Qcom = "VK_QCOM_extension_522"
        case externalFenceFdKhr = "VK_KHR_external_fence_fd"
        case externalFenceKhr = "VK_KHR_external_fence"
        case externalFenceWin32Khr = "VK_KHR_external_fence_win32"
        case externalMemoryAndroidHardwareBufferAndroid = "VK_ANDROID_external_memory_android_hardware_buffer"
        case externalMemoryDmaBufExt = "VK_EXT_external_memory_dma_buf"
        case externalMemoryFdKhr = "VK_KHR_external_memory_fd"
        case externalMemoryFuchsia = "VK_FUCHSIA_external_memory"
        case externalMemoryHostExt = "VK_EXT_external_memory_host"
        case externalMemoryKhr = "VK_KHR_external_memory"
        case externalMemoryRdmaNv = "VK_NV_external_memory_rdma"
        case externalMemorySciBufNv = "VK_NV_external_memory_sci_buf"
        case externalMemoryWin32Khr = "VK_KHR_external_memory_win32"
        case externalSciSync2Nv = "VK_NV_external_sci_sync2"
        case externalSemaphoreFdKhr = "VK_KHR_external_semaphore_fd"
        case externalSemaphoreFuchsia = "VK_FUCHSIA_external_semaphore"
        case externalSemaphoreKhr = "VK_KHR_external_semaphore"
        case externalSemaphoreWin32Khr = "VK_KHR_external_semaphore_win32"
        case fillRectangleNv = "VK_NV_fill_rectangle"
        case filterCubicExt = "VK_EXT_filter_cubic"
        case filterCubicImg = "VK_IMG_filter_cubic"
        case formatFeatureFlags2Khr = "VK_KHR_format_feature_flags2"
        case formatPvrtcImg = "VK_IMG_format_pvrtc"
        case fourFourFourFourFormatsExt = "VK_EXT_4444_formats"
        case fragmentCoverageToColorNv = "VK_NV_fragment_coverage_to_color"
        case fragmentDensityMap2Ext = "VK_EXT_fragment_density_map2"
        case fragmentDensityMapExt = "VK_EXT_fragment_density_map"
        case fragmentDensityMapOffsetQcom = "VK_QCOM_fragment_density_map_offset"
        case fragmentShaderBarycentricKhr = "VK_KHR_fragment_shader_barycentric"
        case fragmentShaderBarycentricNv = "VK_NV_fragment_shader_barycentric"
        case fragmentShaderInterlockExt = "VK_EXT_fragment_shader_interlock"
        case fragmentShadingRateEnumsNv = "VK_NV_fragment_shading_rate_enums"
        case fragmentShadingRateKhr = "VK_KHR_fragment_shading_rate"
        case frameTokenGgp = "VK_GGP_frame_token"
        case framebufferMixedSamplesNv = "VK_NV_framebuffer_mixed_samples"
        case fullScreenExclusiveExt = "VK_EXT_full_screen_exclusive"
        case gcnShaderAmd = "VK_AMD_gcn_shader"
        case geometryShaderPassthroughNv = "VK_NV_geometry_shader_passthrough"
        case getMemoryRequirements2Khr = "VK_KHR_get_memory_requirements2"
        case globalPriorityExt = "VK_EXT_global_priority"
        case globalPriorityKhr = "VK_KHR_global_priority"
        case globalPriorityQueryExt = "VK_EXT_global_priority_query"
        case glslShaderNv = "VK_NV_glsl_shader"
        case graphicsPipelineLibraryExt = "VK_EXT_graphics_pipeline_library"
        case hdrMetadataExt = "VK_EXT_hdr_metadata"
        case hlslFunctionality1Google = "VK_GOOGLE_hlsl_functionality1"
        case hostQueryResetExt = "VK_EXT_host_query_reset"
        case image2DViewOf3DExt = "VK_EXT_image_2d_view_of_3d"
        case imageCompressionControlExt = "VK_EXT_image_compression_control"
        case imageCompressionControlSwapchainExt = "VK_EXT_image_compression_control_swapchain"
        case imageDrmFormatModifierExt = "VK_EXT_image_drm_format_modifier"
        case imageFormatListKhr = "VK_KHR_image_format_list"
        case imageProcessingQcom = "VK_QCOM_image_processing"
        case imageRobustnessExt = "VK_EXT_image_robustness"
        case imageSlicedViewOf3DExt = "VK_EXT_image_sliced_view_of_3d"
        case imageViewHandleNvx = "VK_NVX_image_view_handle"
        case imageViewMinLodExt = "VK_EXT_image_view_min_lod"
        case imagelessFramebufferKhr = "VK_KHR_imageless_framebuffer"
        case incrementalPresentKhr = "VK_KHR_incremental_present"
        case indexTypeUint8Ext = "VK_EXT_index_type_uint8"
        case inheritedViewportScissorNv = "VK_NV_inherited_viewport_scissor"
        case inlineUniformBlockExt = "VK_EXT_inline_uniform_block"
        case invocationMaskHuawei = "VK_HUAWEI_invocation_mask"
        case legacyDitheringExt = "VK_EXT_legacy_dithering"
        case lineRasterizationExt = "VK_EXT_line_rasterization"
        case linearColorAttachmentNv = "VK_NV_linear_color_attachment"
        case loadStoreOpNoneExt = "VK_EXT_load_store_op_none"
        case lowLatencyNv = "VK_NV_low_latency"
        case maintenance1Khr = "VK_KHR_maintenance1"
        case maintenance2Khr = "VK_KHR_maintenance2"
        case maintenance3Khr = "VK_KHR_maintenance3"
        case maintenance4Khr = "VK_KHR_maintenance4"
        case mapMemory2Khr = "VK_KHR_map_memory2"
        case memoryBudgetExt = "VK_EXT_memory_budget"
        case memoryDecompressionNv = "VK_NV_memory_decompression"
        case memoryOverallocationBehaviorAmd = "VK_AMD_memory_overallocation_behavior"
        case memoryPriorityExt = "VK_EXT_memory_priority"
        case meshShaderExt = "VK_EXT_mesh_shader"
        case meshShaderNv = "VK_NV_mesh_shader"
        case metalObjectsExt = "VK_EXT_metal_objects"
        case mixedAttachmentSamplesAmd = "VK_AMD_mixed_attachment_samples"
        case multiDrawExt = "VK_EXT_multi_draw"
        case multisampledRenderToSingleSampledExt = "VK_EXT_multisampled_render_to_single_sampled"
        case multiviewKhr = "VK_KHR_multiview"
        case multiviewPerViewAttributesNvx = "VK_NVX_multiview_per_view_attributes"
        case multiviewPerViewRenderAreasQcom = "VK_QCOM_multiview_per_view_render_areas"
        case multiviewPerViewViewportsQcom = "VK_QCOM_multiview_per_view_viewports"
        case mutableDescriptorTypeExt = "VK_EXT_mutable_descriptor_type"
        case mutableDescriptorTypeValve = "VK_VALVE_mutable_descriptor_type"
        case nativeBufferAndroid = "VK_ANDROID_native_buffer"
        case negativeViewportHeightAmd = "VK_AMD_negative_viewport_height"
        case nonSeamlessCubeMapExt = "VK_EXT_non_seamless_cube_map"
        case objectRefreshKhr = "VK_KHR_object_refresh"
        case opacityMicromapExt = "VK_EXT_opacity_micromap"
        case opticalFlowNv = "VK_NV_optical_flow"
        case pageableDeviceLocalMemoryExt = "VK_EXT_pageable_device_local_memory"
        case pciBusInfoExt = "VK_EXT_pci_bus_info"
        case performanceQueryIntel = "VK_INTEL_performance_query"
        case performanceQueryKhr = "VK_KHR_performance_query"
        case physicalDeviceDrmExt = "VK_EXT_physical_device_drm"
        case pipelineCompilerControlAmd = "VK_AMD_pipeline_compiler_control"
        case pipelineCreationCacheControlExt = "VK_EXT_pipeline_creation_cache_control"
        case pipelineCreationFeedbackExt = "VK_EXT_pipeline_creation_feedback"
        case pipelineExecutablePropertiesKhr = "VK_KHR_pipeline_executable_properties"
        case pipelineLibraryGroupHandlesExt = "VK_EXT_pipeline_library_group_handles"
        case pipelineLibraryKhr = "VK_KHR_pipeline_library"
        case pipelinePropertiesExt = "VK_EXT_pipeline_properties"
        case pipelineProtectedAccessExt = "VK_EXT_pipeline_protected_access"
        case pipelineRobustnessExt = "VK_EXT_pipeline_robustness"
        case portabilitySubsetKhr = "VK_KHR_portability_subset"
        case postDepthCoverageExt = "VK_EXT_post_depth_coverage"
        case presentBarrierNv = "VK_NV_present_barrier"
        case presentIdKhr = "VK_KHR_present_id"
        case presentWaitKhr = "VK_KHR_present_wait"
        case primitiveTopologyListRestartExt = "VK_EXT_primitive_topology_list_restart"
        case primitivesGeneratedQueryExt = "VK_EXT_primitives_generated_query"
        case privateDataExt = "VK_EXT_private_data"
        case privateVendorInfoNv = "VK_NV_private_vendor_info"
        case provokingVertexExt = "VK_EXT_provoking_vertex"
        case pushDescriptorKhr = "VK_KHR_push_descriptor"
        case queueFamilyForeignExt = "VK_EXT_queue_family_foreign"
        case rasterizationOrderAmd = "VK_AMD_rasterization_order"
        case rasterizationOrderAttachmentAccessArm = "VK_ARM_rasterization_order_attachment_access"
        case rasterizationOrderAttachmentAccessExt = "VK_EXT_rasterization_order_attachment_access"
        case rayQueryKhr = "VK_KHR_ray_query"
        case rayTracingInvocationReorderNv = "VK_NV_ray_tracing_invocation_reorder"
        case rayTracingMaintenance1Khr = "VK_KHR_ray_tracing_maintenance1"
        case rayTracingMotionBlurNv = "VK_NV_ray_tracing_motion_blur"
        case rayTracingNv = "VK_NV_ray_tracing"
        case rayTracingPipelineKhr = "VK_KHR_ray_tracing_pipeline"
        case rayTracingPositionFetchKhr = "VK_KHR_ray_tracing_position_fetch"
        case relaxedBlockLayoutKhr = "VK_KHR_relaxed_block_layout"
        case renderPassShaderResolveQcom = "VK_QCOM_render_pass_shader_resolve"
        case renderPassStoreOpsQcom = "VK_QCOM_render_pass_store_ops"
        case renderPassTransformQcom = "VK_QCOM_render_pass_transform"
        case representativeFragmentTestNv = "VK_NV_representative_fragment_test"
        case rgba10x6FormatsExt = "VK_EXT_rgba10x6_formats"
        case robustness2Ext = "VK_EXT_robustness2"
        case rotatedCopyCommandsQcom = "VK_QCOM_rotated_copy_commands"
        case sampleLocationsExt = "VK_EXT_sample_locations"
        case sampleMaskOverrideCoverageNv = "VK_NV_sample_mask_override_coverage"
        case samplerFilterMinmaxExt = "VK_EXT_sampler_filter_minmax"
        case samplerMirrorClampToEdgeKhr = "VK_KHR_sampler_mirror_clamp_to_edge"
        case samplerYcbcrConversionKhr = "VK_KHR_sampler_ycbcr_conversion"
        case scalarBlockLayoutExt = "VK_EXT_scalar_block_layout"
        case scissorExclusiveNv = "VK_NV_scissor_exclusive"
        case separateDepthStencilLayoutsKhr = "VK_KHR_separate_depth_stencil_layouts"
        case separateStencilUsageExt = "VK_EXT_separate_stencil_usage"
        case shaderAtomicFloat2Ext = "VK_EXT_shader_atomic_float2"
        case shaderAtomicFloatExt = "VK_EXT_shader_atomic_float"
        case shaderAtomicInt64Khr = "VK_KHR_shader_atomic_int64"
        case shaderBallotAmd = "VK_AMD_shader_ballot"
        case shaderClockKhr = "VK_KHR_shader_clock"
        case shaderCoreBuiltinsArm = "VK_ARM_shader_core_builtins"
        case shaderCoreProperties2Amd = "VK_AMD_shader_core_properties2"
        case shaderCorePropertiesAmd = "VK_AMD_shader_core_properties"
        case shaderCorePropertiesArm = "VK_ARM_shader_core_properties"
        case shaderDemoteToHelperInvocationExt = "VK_EXT_shader_demote_to_helper_invocation"
        case shaderDrawParametersKhr = "VK_KHR_shader_draw_parameters"
        case shaderEarlyAndLateFragmentTestsAmd = "VK_AMD_shader_early_and_late_fragment_tests"
        case shaderExplicitVertexParameterAmd = "VK_AMD_shader_explicit_vertex_parameter"
        case shaderFloat16Int8Khr = "VK_KHR_shader_float16_int8"
        case shaderFloatControlsKhr = "VK_KHR_shader_float_controls"
        case shaderFragmentMaskAmd = "VK_AMD_shader_fragment_mask"
        case shaderImageAtomicInt64Ext = "VK_EXT_shader_image_atomic_int64"
        case shaderImageFootprintNv = "VK_NV_shader_image_footprint"
        case shaderImageLoadStoreLodAmd = "VK_AMD_shader_image_load_store_lod"
        case shaderInfoAmd = "VK_AMD_shader_info"
        case shaderIntegerDotProductKhr = "VK_KHR_shader_integer_dot_product"
        case shaderIntegerFunctions2Intel = "VK_INTEL_shader_integer_functions2"
        case shaderModuleIdentifierExt = "VK_EXT_shader_module_identifier"
        case shaderNonSemanticInfoKhr = "VK_KHR_shader_non_semantic_info"
        case shaderObjectExt = "VK_EXT_shader_object"
        case shaderSmBuiltinsNv = "VK_NV_shader_sm_builtins"
        case shaderStencilExportExt = "VK_EXT_shader_stencil_export"
        case shaderSubgroupExtendedTypesKhr = "VK_KHR_shader_subgroup_extended_types"
        case shaderSubgroupPartitionedNv = "VK_NV_shader_subgroup_partitioned"
        case shaderSubgroupUniformControlFlowKhr = "VK_KHR_shader_subgroup_uniform_control_flow"
        case shaderTerminateInvocationKhr = "VK_KHR_shader_terminate_invocation"
        case shaderTileImageExt = "VK_EXT_shader_tile_image"
        case shaderTrinaryMinmaxAmd = "VK_AMD_shader_trinary_minmax"
        case shaderViewportIndexLayerExt = "VK_EXT_shader_viewport_index_layer"
        case shadingRateImageNv = "VK_NV_shading_rate_image"
        case sharedPresentableImageKhr = "VK_KHR_shared_presentable_image"
        case sixteenbitStorageKhr = "VK_KHR_16bit_storage"
        case spirv14Khr = "VK_KHR_spirv_1_4"
        case storageBufferStorageClassKhr = "VK_KHR_storage_buffer_storage_class"
        case subgroupSizeControlExt = "VK_EXT_subgroup_size_control"
        case subpassMergeFeedbackExt = "VK_EXT_subpass_merge_feedback"
        case subpassShadingHuawei = "VK_HUAWEI_subpass_shading"
        case swapchainKhr = "VK_KHR_swapchain"
        case swapchainMaintenance1Ext = "VK_EXT_swapchain_maintenance1"
        case swapchainMutableFormatKhr = "VK_KHR_swapchain_mutable_format"
        case synchronization2Khr = "VK_KHR_synchronization2"
        case texelBufferAlignmentExt = "VK_EXT_texel_buffer_alignment"
        case textureCompressionAstcHdrExt = "VK_EXT_texture_compression_astc_hdr"
        case textureGatherBiasLodAmd = "VK_AMD_texture_gather_bias_lod"
        case tilePropertiesQcom = "VK_QCOM_tile_properties"
        case timelineSemaphoreKhr = "VK_KHR_timeline_semaphore"
        case toolingInfoExt = "VK_EXT_tooling_info"
        case transformFeedbackExt = "VK_EXT_transform_feedback"
        case uniformBufferStandardLayoutKhr = "VK_KHR_uniform_buffer_standard_layout"
        case userTypeGoogle = "VK_GOOGLE_user_type"
        case validationCacheExt = "VK_EXT_validation_cache"
        case variablePointersKhr = "VK_KHR_variable_pointers"
        case vertexAttributeDivisorExt = "VK_EXT_vertex_attribute_divisor"
        case vertexInputDynamicStateExt = "VK_EXT_vertex_input_dynamic_state"
        case videoDecodeH264Khr = "VK_KHR_video_decode_h264"
        case videoDecodeH265Khr = "VK_KHR_video_decode_h265"
        case videoDecodeQueueKhr = "VK_KHR_video_decode_queue"
        case videoEncodeH264Ext = "VK_EXT_video_encode_h264"
        case videoEncodeH265Ext = "VK_EXT_video_encode_h265"
        case videoEncodeQueueKhr = "VK_KHR_video_encode_queue"
        case videoQueueKhr = "VK_KHR_video_queue"
        case viewportArray2Nv = "VK_NV_viewport_array2"
        case viewportSwizzleNv = "VK_NV_viewport_swizzle"
        case vulkanMemoryModelKhr = "VK_KHR_vulkan_memory_model"
        case win32KeyedMutexKhr = "VK_KHR_win32_keyed_mutex"
        case win32KeyedMutexNv = "VK_NV_win32_keyed_mutex"
        case workgroupMemoryExplicitLayoutKhr = "VK_KHR_workgroup_memory_explicit_layout"
        case ycbcr2Plane444FormatsExt = "VK_EXT_ycbcr_2plane_444_formats"
        case ycbcrImageArraysExt = "VK_EXT_ycbcr_image_arrays"
        case zeroInitializeWorkgroupMemoryKhr = "VK_KHR_zero_initialize_workgroup_memory"
    }

#endif // VULKAN_VERSION_1_3_249
