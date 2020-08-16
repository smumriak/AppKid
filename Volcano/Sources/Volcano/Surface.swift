//
//  Surface.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan
import CX11.Xlib
import CX11.X

public final class Surface: VulkanEntity<SmartPointer<VkSurfaceKHR_T>> {
    public unowned let physicalDevice: PhysicalDevice
    public let supportedFormats: [VkSurfaceFormatKHR]
    public let selectedFormat: VkSurfaceFormatKHR
    public var imageFormat: VkFormat { return selectedFormat.format }
    public var colorSpace: VkColorSpaceKHR { return selectedFormat.colorSpace }
    public let capabilities: VkSurfaceCapabilitiesKHR
    public let presetModes: [VkPresentModeKHR]

    internal init(physicalDevice: PhysicalDevice, display: UnsafeMutablePointer<Display>, window: Window) throws {
        self.physicalDevice = physicalDevice

        let instance = physicalDevice.instance

        #if os(Linux)
        var info: VkXlibSurfaceCreateInfoKHR = VkXlibSurfaceCreateInfoKHR()
        info.sType = VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR
        info.dpy = display
        info.window = window
        #elseif os(macOS)
        var info = VkMacOSSurfaceCreateInfoMVK()
        info.sType = VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK
        #else
        #error("Wrong OS! (For now)")
        #endif

        let handlePointer = try instance.create(with: info)

        let supportedFormats = try physicalDevice.loadDataArray(for: handlePointer.pointer, using: vkGetPhysicalDeviceSurfaceFormatsKHR)
        if supportedFormats.isEmpty {
            fatalError("No surface formates available")
        }

        let desiredFormat = VkSurfaceFormatKHR(format: VK_FORMAT_B8G8R8A8_UNORM, colorSpace: VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)

        if supportedFormats.contains(desiredFormat) || (supportedFormats.count == 1 && supportedFormats[0].format == VK_FORMAT_UNDEFINED) {
            selectedFormat = desiredFormat
        } else {
            selectedFormat = supportedFormats[0]
        }

        self.supportedFormats = supportedFormats

        capabilities = try physicalDevice.loadData(for: handlePointer.pointer, using: vkGetPhysicalDeviceSurfaceCapabilitiesKHR)
        presetModes = try physicalDevice.loadDataArray(for: handlePointer.pointer, using: vkGetPhysicalDeviceSurfacePresentModesKHR)

        try super.init(instance: instance, handlePointer: handlePointer)
    }

    func supportsPresenting(onQueueFamilyIndex queueFamilyIndex: Int) throws -> Bool {
        var supportsPresentingVKBool: VkBool32 = VkBool32(VK_FALSE)
        try vulkanInvoke {
            vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice.handle, UInt32(queueFamilyIndex), handle, &supportsPresentingVKBool)
        }
        return supportsPresentingVKBool == VkBool32(VK_FALSE) ? false : true
    }
}

extension VkSurfaceFormatKHR: Equatable {
    public static func == (lhs: VkSurfaceFormatKHR, rhs: VkSurfaceFormatKHR) -> Bool {
        return lhs.format == rhs.format && lhs.colorSpace == rhs.colorSpace
    }
}

public extension Shader {
    fileprivate static let defaultShaderEntryPointName = strdup("main")

    func createStageInfo(for stage: VkShaderStageFlagBits, flags: VkPipelineShaderStageCreateFlagBits = []) -> VkPipelineShaderStageCreateInfo {
        var result = VkPipelineShaderStageCreateInfo()
        
        result.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
        result.pNext = nil
        result.flags = flags.rawValue
        result.stage = stage
        result.module = handle
        result.pName = UnsafePointer(Shader.defaultShaderEntryPointName)
        result.pSpecializationInfo = nil

        return result
    }
}
