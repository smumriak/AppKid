//
//  VulkanDevice.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

extension VkDevice_T: ReleasableCType {
    public static var releaseFunc: (UnsafeMutablePointer<VkDevice_T>?) -> () {
        return {
            vkDestroyDevice($0, nil)
        }
    }
}

internal extension ReleasablePointer where Pointee == VkDevice_T {
    func loadFunction<Function>(with name: String) throws -> Function {
        guard let result = cVulkanGetDeviceProcAddr(pointer, name) else {
            throw VulkanError.deviceFunctionNotFound(name)
        }

        return unsafeBitCast(result, to: Function.self)
    }
}

extension VkDevice_T: EntityFactory {}
extension VkDevice_T: DataLoader {}

public final class VulkanDevice: VulkanEntity<ReleasablePointer<VkDevice_T>> {
    public unowned let surface: VulkanSurface

    public let graphicsQueueFamilyIndex: Int
    public let presentationQueueFamilyIndex: Int

    public internal(set) lazy var graphicsQueue: VulkanQueue = {
        do {
            return try VulkanQueue(device: self, familyIndex: graphicsQueueFamilyIndex, queueIndex: 0)
        } catch {
            fatalError("Failed to retrieve graphics from vulkan with error: \(error)")
        }
    }()

    public internal(set) lazy var presentationQueue: VulkanQueue = {
        do {
            return try VulkanQueue(device: self, familyIndex: presentationQueueFamilyIndex, queueIndex: 0)
        } catch {
            fatalError("Failed to retrieve gresentation from vulkan with error: \(error)")
        }
    }()

    internal let vkCreateSwapchainKHR: PFN_vkCreateSwapchainKHR
    internal let vkDestroySwapchainKHR: PFN_vkDestroySwapchainKHR
    internal let vkGetSwapchainImagesKHR: PFN_vkGetSwapchainImagesKHR
    internal let vkAcquireNextImageKHR: PFN_vkAcquireNextImageKHR
    internal let vkQueuePresentKHR: PFN_vkQueuePresentKHR

    public init(surface: VulkanSurface) throws {
        self.surface = surface
        let physicalDevice = surface.physicalDevice

        var deviceCreationInfo: VkDeviceCreateInfo = VkDeviceCreateInfo()
        deviceCreationInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
        deviceCreationInfo.flags = 0

        var enabledFeatures = physicalDevice.features
        withUnsafePointer(to: &enabledFeatures) {
            deviceCreationInfo.pEnabledFeatures = $0
        }

        var queuePrioririesPointer = UnsafeMutablePointer<Float>.allocate(capacity: 1)
        defer { queuePrioririesPointer.deallocate() }
        queuePrioririesPointer.initialize(to: 1.0)

        let queueFamiliesProperties = physicalDevice.queueFamiliesProperties.enumerated()

        let presentationQueueOffsetPair = try queueFamiliesProperties.first {
            try surface.supportsPresenting(onQueueFamilyIndex: $0.offset)
        }

        guard let presentationQueueFamilyIndex = presentationQueueOffsetPair?.offset else {
            fatalError("No queues that support image presenting")
        }

        self.presentationQueueFamilyIndex = presentationQueueFamilyIndex

        let graphicsQueueOffsetPair = queueFamiliesProperties.first {
            $0.element.isGraphics
        }

        guard let graphicsQueueFamilyIndex = graphicsQueueOffsetPair?.offset else {
            fatalError("No queues that support rendering")
        }

        self.graphicsQueueFamilyIndex = graphicsQueueFamilyIndex

        let deviceQueueCreationInfos: [VkDeviceQueueCreateInfo] = try queueFamiliesProperties
            .filter { return try $0.element.isGraphics || surface.supportsPresenting(onQueueFamilyIndex: $0.offset) }
            .map {
                var result = VkDeviceQueueCreateInfo()
                result.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
                result.flags = 0
                result.queueFamilyIndex = CUnsignedInt($0.offset)
                result.queueCount = 1
                result.pQueuePriorities = UnsafePointer(queuePrioririesPointer)
                return result
        }

        deviceCreationInfo.queueCreateInfoCount = CUnsignedInt(deviceQueueCreationInfos.count)
        deviceQueueCreationInfos.withUnsafeBufferPointer {
            deviceCreationInfo.pQueueCreateInfos = $0.baseAddress
        }

        var extensions: [UnsafeMutablePointer<Int8>] = []
        defer { extensions.forEach { free($0) } }

        extensions.append(strdup(VK_KHR_SWAPCHAIN_EXTENSION_NAME))

        var extensionsPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: extensions.count)
        defer { extensionsPointer.deallocate() }

        extensions.enumerated().forEach {
            extensionsPointer[$0.offset] = UnsafePointer($0.element)
        }

        deviceCreationInfo.enabledExtensionCount = CUnsignedInt(extensions.count)
        deviceCreationInfo.ppEnabledExtensionNames = UnsafePointer(extensionsPointer)

        let devicePointer: VkDevice = try physicalDevice.handle.createEntity(info: &deviceCreationInfo, using: vkCreateDevice)
        let handlePointer = ReleasablePointer(with: devicePointer)

        vkCreateSwapchainKHR = try handlePointer.loadFunction(with: "vkCreateSwapchainKHR")
        vkDestroySwapchainKHR = try handlePointer.loadFunction(with: "vkDestroySwapchainKHR")
        vkGetSwapchainImagesKHR = try handlePointer.loadFunction(with: "vkGetSwapchainImagesKHR")
        vkAcquireNextImageKHR = try handlePointer.loadFunction(with: "vkAcquireNextImageKHR")
        vkQueuePresentKHR = try handlePointer.loadFunction(with: "vkQueuePresentKHR")

        try super.init(instance: physicalDevice.instance, handlePointer: handlePointer)
    }
}
