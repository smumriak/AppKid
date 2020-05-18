//
//  VulkanInstance.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

extension VkInstance_T: DestructableCType {
    public var destroyFunc: (UnsafeMutablePointer<VkInstance_T>?) -> () {
        return {
            vkDestroyInstance($0, nil)
        }
    }
}

internal extension DestructablePointer where Pointee == VkInstance_T {
    func loadFunction<Function>(with name: String) throws -> Function {
        guard let result = cVulkanGetInstanceProcAddr(pointer, name) else {
            throw VulkanError.instanceFunctionNotFound(name)
        }

        return unsafeBitCast(result, to: Function.self)
    }
}

public final class VulkanInstance: VulkanHandle<DestructablePointer<VkInstance_T>> {
    internal let getPhysicalDeviceSurfaceSupportKHR: PFN_vkGetPhysicalDeviceSurfaceSupportKHR
    internal let getPhysicalDeviceSurfaceCapabilitiesKHR: PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR
    internal let getPhysicalDeviceSurfaceFormatsKHR: PFN_vkGetPhysicalDeviceSurfaceFormatsKHR
    internal let getPhysicalDeviceSurfacePresentModesKHR: PFN_vkGetPhysicalDeviceSurfacePresentModesKHR

    public init() {
        do {
            var applicationInfo = VkApplicationInfo()
            applicationInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
            applicationInfo.apiVersion =  (1 << 22) | (0 << 12) | 0

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

            let handlePointer = DestructablePointer(with: instanceOptional!)

            getPhysicalDeviceSurfaceSupportKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfaceSupportKHR")
            getPhysicalDeviceSurfaceCapabilitiesKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
            getPhysicalDeviceSurfaceFormatsKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfaceFormatsKHR")
            getPhysicalDeviceSurfacePresentModesKHR = try handlePointer.loadFunction(with: "vkGetPhysicalDeviceSurfacePresentModesKHR")

            super.init(handlePointer: handlePointer)
        } catch {
            fatalError("Could not spawn vulkan instance with error: \(error)")
        }
    }

    public internal(set) lazy var physicalDevices: [VulkanPhysicalDevice] = {
        do {
            var devicesCount: CUnsignedInt = 0
            try vulkanInvoke {
                vkEnumeratePhysicalDevices(handle, &devicesCount, nil)
            }

            var devicesPointer = UnsafeMutablePointer<VkPhysicalDevice?>.allocate(capacity: Int(devicesCount))
            defer { devicesPointer.deallocate() }

            try vulkanInvoke {
                vkEnumeratePhysicalDevices(handle, &devicesCount, devicesPointer)
            }

            return try UnsafeBufferPointer(start: devicesPointer, count: Int(devicesCount))
                .compactMap { $0 }
                .map { try VulkanPhysicalDevice(instance: self, handlePointer: SimplePointer(with: $0)) }
        } catch {
            fatalError("Could not query vulkan devices with error: \(error)")
        }
    }()
}
