//
//  Instance.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
@_exported import TinyFoundation
@_exported import CVulkan

extension VkInstance_T: ReleasableCType {
    public static var releaseFunc: (UnsafeMutablePointer<VkInstance_T>?) -> () {
        return {
            vkDestroyInstance($0, nil)
        }
    }
}

internal extension ReleasablePointer where Pointee == VkInstance_T {
    func loadFunction<Function>(named name: String) throws -> Function {
        guard let result = cVulkanGetInstanceProcAddr(pointer, name) else {
            throw VulkanError.instanceFunctionNotFound(name)
        }

        return unsafeBitCast(result, to: Function.self)
    }
}

extension VkInstance_T: EntityFactory {}
extension VkInstance_T: DataLoader {}

public final class Instance: VulkanHandle<ReleasablePointer<VkInstance_T>> {
    internal let vkGetPhysicalDeviceSurfaceSupportKHR: PFN_vkGetPhysicalDeviceSurfaceSupportKHR
    internal let vkGetPhysicalDeviceSurfaceCapabilitiesKHR: PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR
    internal let vkGetPhysicalDeviceSurfaceFormatsKHR: PFN_vkGetPhysicalDeviceSurfaceFormatsKHR
    internal let vkGetPhysicalDeviceSurfacePresentModesKHR: PFN_vkGetPhysicalDeviceSurfacePresentModesKHR

    public internal(set) lazy var physicalDevices: [PhysicalDevice] = {
        do {
            return try loadDataArray(using: vkEnumeratePhysicalDevices)
                .compactMap { $0 }
                .map { try PhysicalDevice(instance: self, handlePointer: SmartPointer(with: $0)) }
                .sorted(by: >)
        } catch {
            fatalError("Could not query vulkan devices with error: \(error)")
        }
    }()

    public internal(set) lazy var discreteGPUDevice: PhysicalDevice? = physicalDevices.first
    
    public init() {
        do {
            var applicationInfo = VkApplicationInfo()
            applicationInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
            applicationInfo.apiVersion =  (1 << 22) | (2 << 12) | 0

            let validationLayers = ["VK_LAYER_KHRONOS_validation"].cStrings
            let validationLayersPointer = SmartPointer<UnsafePointer<Int8>?>.allocate(capacity: validationLayers.count)

            validationLayers.enumerated().forEach {
                validationLayersPointer.pointer[$0.offset] = UnsafePointer($0.element.pointer)
            }

            var instanceCreationInfo = VkInstanceCreateInfo()
            instanceCreationInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
            instanceCreationInfo.enabledLayerCount = CUnsignedInt(validationLayers.count)
            instanceCreationInfo.ppEnabledLayerNames = UnsafePointer(validationLayersPointer.pointer)

            withUnsafePointer(to: &applicationInfo) {
                instanceCreationInfo.pApplicationInfo = $0
            }

            var extensions: [String] = [VK_KHR_SURFACE_EXTENSION_NAME]

            #if os(Linux)
            extensions.append(VK_KHR_XLIB_SURFACE_EXTENSION_NAME)
            #endif

            let extensionsCStrings = extensions.cStrings

            let extensionsPointer = SmartPointer<UnsafePointer<Int8>?>.allocate(capacity: extensionsCStrings.count)

            extensionsCStrings.enumerated().forEach {
                extensionsPointer.pointer[$0.offset] = UnsafePointer($0.element.pointer)
            }

            instanceCreationInfo.enabledExtensionCount = CUnsignedInt(extensionsCStrings.count)
            instanceCreationInfo.ppEnabledExtensionNames = UnsafePointer(extensionsPointer.pointer)

            var instanceOptional: VkInstance?

            try vulkanInvoke {
                vkCreateInstance(&instanceCreationInfo, nil, &instanceOptional)
            }

            let handlePointer = ReleasablePointer(with: instanceOptional!)

            vkGetPhysicalDeviceSurfaceSupportKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfaceSupportKHR")
            vkGetPhysicalDeviceSurfaceCapabilitiesKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
            vkGetPhysicalDeviceSurfaceFormatsKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfaceFormatsKHR")
            vkGetPhysicalDeviceSurfacePresentModesKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfacePresentModesKHR")

            super.init(handlePointer: handlePointer)
        } catch {
            fatalError("Could not spawn vulkan instance with error: \(error)")
        }
    }
}
