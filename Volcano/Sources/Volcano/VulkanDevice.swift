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

extension VkDevice_T: VulkanEntityFactory {}

public final class VulkanDevice: VulkanEntity<DestructablePointer<VkDevice_T>> {
    public unowned let physicalDevice: VulkanPhysicalDevice

    internal let vkCreateSwapchainKHR: PFN_vkCreateSwapchainKHR
    internal let vkDestroySwapchainKHR: PFN_vkDestroySwapchainKHR
    internal let vkGetSwapchainImagesKHR: PFN_vkGetSwapchainImagesKHR
    internal let vkAcquireNextImageKHR: PFN_vkAcquireNextImageKHR
    internal let vkQueuePresentKHR: PFN_vkQueuePresentKHR

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

        self.physicalDevice = physicalDevice
        let devicePointer: VkDevice = try physicalDevice.handle.createEntity(info: &deviceCreationInfo, using: vkCreateDevice)
        let handlePointer = DestructablePointer(with: devicePointer)

        vkCreateSwapchainKHR = try handlePointer.loadFunction(with: "vkCreateSwapchainKHR")
        vkDestroySwapchainKHR = try handlePointer.loadFunction(with: "vkDestroySwapchainKHR")
        vkGetSwapchainImagesKHR = try handlePointer.loadFunction(with: "vkGetSwapchainImagesKHR")
        vkAcquireNextImageKHR = try handlePointer.loadFunction(with: "vkAcquireNextImageKHR")
        vkQueuePresentKHR = try handlePointer.loadFunction(with: "vkQueuePresentKHR")

        try super.init(instance: physicalDevice.instance, handlePointer: handlePointer)
    }
}
