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

public final class Instance: HandleStorage<ReleasablePointer<VkInstance_T>> {
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
    
    public init(extensions: Set<VulkanExtensionName> = []) {
        do {
            var applicationInfo = VkApplicationInfo()
            applicationInfo.sType = .applicationInfo
            applicationInfo.apiVersion = (1 << 22) | (0 << 12) | 0
            var layers: [String] = []
            
            layers.append("VK_LAYER_KHRONOS_validation")

            var extensions = extensions
            extensions.formUnion([.getPhysicalDeviceProperties2, .getSurfaceCapabilities2])

            #if os(Linux)
                extensions.insert(.externalFenceCapabilities)
            #elseif os(Windows)
                extensions.insert(.externalFenceCapabilities)
            #endif

            let handlePointer: ReleasablePointer<VkInstance_T> = try layers.withUnsafeNullableCStringsBufferPointer { layers in
                try extensions.map { $0.rawValue }
                    .withUnsafeNullableCStringsBufferPointer { extensions in
                        var info = VkInstanceCreateInfo()
                        info.sType = .instanceCreateInfo
                        info.enabledLayerCount = CUnsignedInt(layers.count)
                        info.ppEnabledLayerNames = layers.baseAddress!

                        withUnsafePointer(to: &applicationInfo) {
                            info.pApplicationInfo = $0
                        }

                        info.enabledExtensionCount = CUnsignedInt(extensions.count)
                        info.ppEnabledExtensionNames = extensions.baseAddress!

                        var instanceOptional: VkInstance?

                        let chain = VulkanStructureChain(root: info)

                        try chain.withUnsafeChainPointer { info in
                            try vulkanInvoke {
                                vkCreateInstance(info, nil, &instanceOptional)
                            }
                        }

                        return ReleasablePointer(with: instanceOptional!)
                    }
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
