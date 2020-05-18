//
//  VulkanDevice.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

extension VkDevice_T: DestructableCType {
    public var destroyFunc: (UnsafeMutablePointer<VkDevice_T>?) -> () {
        return {
            vkDestroyDevice($0, nil)
        }
    }
}

internal extension DestructablePointer where Pointee == VkDevice_T {
    func loadFunction<Function>(with name: String) throws -> Function {
        guard let result = cVulkanGetDeviceProcAddr(pointer, name) else {
            throw VulkanError.deviceFunctionNotFound(name)
        }

        return unsafeBitCast(result, to: Function.self)
    }
}

public final class VulkanDevice: VulkanEntity<DestructablePointer<VkDevice_T>> {
    public unowned let physicalDevice: VulkanPhysicalDevice

    internal let createSwapchainKHR: PFN_vkCreateSwapchainKHR
    internal let destroySwapchainKHR: PFN_vkDestroySwapchainKHR
    internal let getSwapchainImagesKHR: PFN_vkGetSwapchainImagesKHR
    internal let acquireNextImageKHR: PFN_vkAcquireNextImageKHR
    internal let queuePresentKHR: PFN_vkQueuePresentKHR

    internal init(physicalDevice: VulkanPhysicalDevice) throws {
        var deviceQueueCreationInfo = VkDeviceQueueCreateInfo()
        deviceQueueCreationInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
        deviceQueueCreationInfo.flags = 0;
        deviceQueueCreationInfo.queueFamilyIndex = 0;
        deviceQueueCreationInfo.queueCount = 1;

        var queuePrioririesPointer = UnsafeMutablePointer<Float>.allocate(capacity: Int(deviceQueueCreationInfo.queueCount))
        defer { queuePrioririesPointer.deallocate() }
        queuePrioririesPointer.initialize(to: 1.0)

        deviceQueueCreationInfo.pQueuePriorities = UnsafePointer(queuePrioririesPointer)

        var deviceCreationInfo: VkDeviceCreateInfo = VkDeviceCreateInfo()
        deviceCreationInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
        deviceCreationInfo.flags = 0;
        deviceCreationInfo.queueCreateInfoCount = 1;
        withUnsafePointer(to: &deviceQueueCreationInfo) {
            deviceCreationInfo.pQueueCreateInfos = $0
        }

        var extensions: [UnsafeMutablePointer<Int8>] = []

        extensions.append(strdup(VK_KHR_SWAPCHAIN_EXTENSION_NAME))

        defer { extensions.forEach { free($0) } }

        var extensionsPointerpointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: extensions.count)
        defer { extensionsPointerpointer.deallocate() }

        extensions.enumerated().forEach {
            extensionsPointerpointer[$0.offset] = UnsafePointer($0.element)
        }

        deviceCreationInfo.enabledExtensionCount = CUnsignedInt(extensions.count)
        deviceCreationInfo.ppEnabledExtensionNames = UnsafePointer(extensionsPointerpointer)

        var deviceOptional: VkDevice?
        try vulkanInvoke {
            vkCreateDevice(physicalDevice.handle, &deviceCreationInfo, nil, &deviceOptional)
        }

        self.physicalDevice = physicalDevice
        let handlePointer = DestructablePointer(with: deviceOptional!)

        createSwapchainKHR = try handlePointer.loadFunction(with: "vkCreateSwapchainKHR")
        destroySwapchainKHR = try handlePointer.loadFunction(with: "vkDestroySwapchainKHR")
        getSwapchainImagesKHR = try handlePointer.loadFunction(with: "vkGetSwapchainImagesKHR")
        acquireNextImageKHR = try handlePointer.loadFunction(with: "vkAcquireNextImageKHR")
        queuePresentKHR = try handlePointer.loadFunction(with: "vkQueuePresentKHR")

        try super.init(instance: physicalDevice.instance, handlePointer: handlePointer)
    }
}
