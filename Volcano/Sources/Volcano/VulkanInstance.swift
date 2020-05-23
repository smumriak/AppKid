//
//  VulkanInstance.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

extension VkInstance_T: ReleasableCType {
    public static var releaseFunc: (UnsafeMutablePointer<VkInstance_T>?) -> () {
        return {
            vkDestroyInstance($0, nil)
        }
    }
}

internal extension ReleasablePointer where Pointee == VkInstance_T {
    func loadFunction<Function>(with name: String) throws -> Function {
        guard let result = cVulkanGetInstanceProcAddr(pointer, name) else {
            throw VulkanError.instanceFunctionNotFound(name)
        }

        return unsafeBitCast(result, to: Function.self)
    }
}

extension VkInstance_T: EntityFactory {}
extension VkInstance_T: DataLoader {}

public final class VulkanInstance: VulkanHandle<ReleasablePointer<VkInstance_T>> {
    internal let vkGetPhysicalDeviceSurfaceSupportKHR: PFN_vkGetPhysicalDeviceSurfaceSupportKHR
    internal let vkGetPhysicalDeviceSurfaceCapabilitiesKHR: PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR
    internal let vkGetPhysicalDeviceSurfaceFormatsKHR: PFN_vkGetPhysicalDeviceSurfaceFormatsKHR
    internal let vkGetPhysicalDeviceSurfacePresentModesKHR: PFN_vkGetPhysicalDeviceSurfacePresentModesKHR

    public internal(set) lazy var physicalDevices: [VulkanPhysicalDevice] = {
        do {
            return try loadDataArray(using: vkEnumeratePhysicalDevices)
                .compactMap { $0 }
                .map { try VulkanPhysicalDevice(instance: self, handlePointer: SmartPointer(with: $0)) }
                .sorted(by: >)
        } catch {
            fatalError("Could not query vulkan devices with error: \(error)")
        }
    }()

    public internal(set) lazy var discreteGPUDevices: VulkanPhysicalDevice? = physicalDevices.first
    
    public init() {
        do {
            var applicationInfo = VkApplicationInfo()
            applicationInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
            applicationInfo.apiVersion =  (1 << 22) | (2 << 12) | 0

            var instanceCreationInfo = VkInstanceCreateInfo()
            instanceCreationInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO

            withUnsafePointer(to: &applicationInfo) {
                instanceCreationInfo.pApplicationInfo = $0
            }

            var extensions: [UnsafeMutablePointer<Int8>] = []

            #if os(Linux)
            extensions.append(strdup(VK_KHR_XLIB_SURFACE_EXTENSION_NAME))
            #endif

            extensions.append(strdup(VK_KHR_SURFACE_EXTENSION_NAME))

            defer { extensions.forEach { free($0) } }

            var extensionsPointerpointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: extensions.count)
            defer { extensionsPointerpointer.deallocate() }

            extensions.enumerated().forEach {
                extensionsPointerpointer[$0.offset] = UnsafePointer($0.element)
            }

            instanceCreationInfo.enabledExtensionCount = CUnsignedInt(extensions.count)
            instanceCreationInfo.ppEnabledExtensionNames = UnsafePointer(extensionsPointerpointer)

            var instanceOptional: VkInstance?

            try vulkanInvoke {
                vkCreateInstance(&instanceCreationInfo, nil, &instanceOptional)
            }

            let handlePointer = ReleasablePointer(with: instanceOptional!)

            vkGetPhysicalDeviceSurfaceSupportKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfaceSupportKHR")
            vkGetPhysicalDeviceSurfaceCapabilitiesKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
            vkGetPhysicalDeviceSurfaceFormatsKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfaceFormatsKHR")
            vkGetPhysicalDeviceSurfacePresentModesKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfacePresentModesKHR")

            super.init(handlePointer: handlePointer)
        } catch {
            fatalError("Could not spawn vulkan instance with error: \(error)")
        }
    }
}
