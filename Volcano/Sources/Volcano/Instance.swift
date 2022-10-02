//
//  Instance.swift
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

internal extension SharedPointer where Pointee == VkInstance_T {
    func loadFunction<Function>(named name: String) throws -> Function {
        guard let result = volcanoGetInstanceProcAddr(pointer, name) else {
            throw VulkanError.instanceFunctionNotFound(name)
        }

        return unsafeBitCast(result, to: Function.self)
    }
}

extension VkInstance_T: EntityFactory {}
extension VkInstance_T: DataLoader {}

public final class Instance: SharedPointerStorage<VkInstance_T> {
    internal let vkGetPhysicalDeviceSurfaceSupportKHR: PFN_vkGetPhysicalDeviceSurfaceSupportKHR
    internal let vkGetPhysicalDeviceSurfaceCapabilitiesKHR: PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR
    internal let vkGetPhysicalDeviceSurfaceCapabilities2KHR: PFN_vkGetPhysicalDeviceSurfaceCapabilities2KHR
    internal let vkGetPhysicalDeviceSurfaceFormatsKHR: PFN_vkGetPhysicalDeviceSurfaceFormatsKHR
    internal let vkGetPhysicalDeviceSurfacePresentModesKHR: PFN_vkGetPhysicalDeviceSurfacePresentModesKHR
    internal let vkGetPhysicalDeviceExternalFenceProperties: PFN_vkGetPhysicalDeviceExternalFenceProperties

    public internal(set) lazy var physicalDevices: [PhysicalDevice] = {
        do {
            return try loadDataArray(using: vkEnumeratePhysicalDevices)
                .compactMap { $0 }
                .map { try PhysicalDevice(instance: self, handle: SharedPointer(with: $0)) }
                .sorted(by: >)
        } catch {
            fatalError("Could not query vulkan devices with error: \(error)")
        }
    }()
    
    public init(extensions: Set<InstanceExtension> = []) {
        do {
            let vulkanVersion: CUnsignedInt = (1 << 22) | (0 << 12) | 0

            var layers: [String] = []
            
            var extensions = extensions + [
                .getPhysicalDeviceProperties2Khr,
                .getSurfaceCapabilities2Khr,
            ]

            #if os(Linux)
                extensions.insert(.externalFenceCapabilitiesKhr)
            #elseif os(Windows)
                extensions.insert(.externalFenceCapabilitiesKhr)
            #endif

            #if DEBUG
                layers.append("VK_LAYER_KHRONOS_validation")
                extensions.insert(.debugUtilsExt)
            #endif

            let handle = try LavaBuilder<VkInstanceCreateInfo> {
                (\.enabledLayerCount, \.ppEnabledLayerNames) <- layers
                \.pApplicationInfo <- {
                    \.apiVersion <- vulkanVersion
                }

                (\.enabledExtensionCount, \.ppEnabledExtensionNames) <- extensions.map { $0.rawValue }
            }
            .withUnsafeResultPointer { info in
                var instanceOptional: VkInstance?

                try vulkanInvoke {
                    vkCreateInstance(info, nil, &instanceOptional)
                }

                return ReleasablePointer(with: instanceOptional!)
            }
            
            vkGetPhysicalDeviceSurfaceSupportKHR = try handle.loadFunction(named: "vkGetPhysicalDeviceSurfaceSupportKHR")
            vkGetPhysicalDeviceSurfaceCapabilitiesKHR = try handle.loadFunction(named: "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
            vkGetPhysicalDeviceSurfaceCapabilities2KHR = try handle.loadFunction(named: "vkGetPhysicalDeviceSurfaceCapabilities2KHR")
            vkGetPhysicalDeviceSurfaceFormatsKHR = try handle.loadFunction(named: "vkGetPhysicalDeviceSurfaceFormatsKHR")
            vkGetPhysicalDeviceSurfacePresentModesKHR = try handle.loadFunction(named: "vkGetPhysicalDeviceSurfacePresentModesKHR")
            vkGetPhysicalDeviceExternalFenceProperties = try handle.loadFunction(named: "vkGetPhysicalDeviceExternalFenceProperties")

            super.init(handle: handle)
        } catch {
            fatalError("Could not spawn vulkan instance with error: \(error)")
        }
    }
}
