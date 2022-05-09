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

internal extension SmartPointer where Pointee == VkInstance_T {
    func loadFunction<Function>(named name: String) throws -> Function {
        guard let result = cVulkanGetInstanceProcAddr(pointer, name) else {
            throw VulkanError.instanceFunctionNotFound(name)
        }

        return unsafeBitCast(result, to: Function.self)
    }
}

extension VkInstance_T: EntityFactory {}
extension VkInstance_T: DataLoader {}

public final class Instance: HandleStorage<SmartPointer<VkInstance_T>> {
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
                .map { try PhysicalDevice(instance: self, handlePointer: SmartPointer(with: $0)) }
                .sorted(by: >)
        } catch {
            fatalError("Could not query vulkan devices with error: \(error)")
        }
    }()
    
    public init(extensions: Set<InstanceExtension> = []) {
        do {
            let vulkanVersion: CUnsignedInt = (1 << 22) | (0 << 12) | 0

            var layers: [String] = []
            
            layers.append("VK_LAYER_KHRONOS_validation")

            var extensions = extensions + [
                .getPhysicalDeviceProperties2Khr,
                .getSurfaceCapabilities2Khr,
            ]

            #if os(Linux)
                extensions.insert(.externalFenceCapabilitiesKhr)
            #elseif os(Windows)
                extensions.insert(.externalFenceCapabilitiesKhr)
            #endif

            let handlePointer: SmartPointer<VkInstance_T> = try VkBuilder<VkInstanceCreateInfo> {
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
            
            vkGetPhysicalDeviceSurfaceSupportKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfaceSupportKHR")
            vkGetPhysicalDeviceSurfaceCapabilitiesKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
            vkGetPhysicalDeviceSurfaceCapabilities2KHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfaceCapabilities2KHR")
            vkGetPhysicalDeviceSurfaceFormatsKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfaceFormatsKHR")
            vkGetPhysicalDeviceSurfacePresentModesKHR = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceSurfacePresentModesKHR")
            vkGetPhysicalDeviceExternalFenceProperties = try handlePointer.loadFunction(named: "vkGetPhysicalDeviceExternalFenceProperties")

            super.init(handlePointer: handlePointer)
        } catch {
            fatalError("Could not spawn vulkan instance with error: \(error)")
        }
    }
}
