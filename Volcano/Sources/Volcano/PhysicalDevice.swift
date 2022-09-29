//
//  PhysicalDevice.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan
import CXlib

extension VkPhysicalDevice_T: EntityFactory {}
extension VkPhysicalDevice_T: DataLoader {}

public final class PhysicalDevice: InstanceEntity<VkPhysicalDevice_T> {
    public let features: VkPhysicalDeviceFeatures
    // public let features11: VkPhysicalDeviceVulkan11Features
    // public let features12: VkPhysicalDeviceVulkan12Features
    public let features2: VkPhysicalDeviceFeatures2
    public let properties: VkPhysicalDeviceProperties
    public let queueFamiliesProperties: [VkQueueFamilyProperties]
    public let deviceType: VkPhysicalDeviceType

    public private(set) lazy var name = String(cStringTuple: properties.deviceName)

    public lazy var queueFamiliesDescriptors: [QueueFamilyDescriptor] = queueFamiliesProperties.enumerated()
        .map { QueueFamilyDescriptor(index: $0, properties: $1) }
        .sorted(by: <)

    public let memoryProperties: VkPhysicalDeviceMemoryProperties
    public let extensionProperties: [VkExtensionProperties]
    public let supportedExtensionsVersions: [DeviceExtension: UInt]

    public lazy var memoryTypes: [VkMemoryType] = {
        return withUnsafeBytes(of: memoryProperties.memoryTypes) {
            let pointer = $0.baseAddress!.assumingMemoryBound(to: VkMemoryType.self)
            let bufferPointer = UnsafeBufferPointer<VkMemoryType>(start: pointer, count: Int(memoryProperties.memoryTypeCount))
            return Array<VkMemoryType>(bufferPointer)
        }
    }()

    public lazy var memoryHeaps: [VkMemoryHeap] = {
        return withUnsafeBytes(of: memoryProperties.memoryHeaps) {
            let pointer = $0.baseAddress!.assumingMemoryBound(to: VkMemoryHeap.self)
            let bufferPointer = UnsafeBufferPointer<VkMemoryHeap>(start: pointer, count: Int(memoryProperties.memoryHeapCount))
            return Array<VkMemoryHeap>(bufferPointer)
        }
    }()

    internal lazy var renderingPerformanceScore: UInt32 = {
        var result: UInt32 = 0
        if features.geometryShader == false.vkBool {
            return 0
        } else {
            result += properties.limits.maxImageDimension2D
            if properties.deviceType == .discreteGpu {
                result += 1000
            }
        }
        return result
    }()

    public private(set) lazy var maximumSampleCount: VkSampleCountFlagBits = {
        let framebufferColorSampleCount = VkSampleCountFlagBits(rawValue: properties.limits.framebufferColorSampleCounts)
        let framebufferDepthSampleCounts = VkSampleCountFlagBits(rawValue: properties.limits.framebufferDepthSampleCounts)
        let supportedSampleCount = framebufferColorSampleCount.intersection(framebufferDepthSampleCounts)

        let sampleCounts: [VkSampleCountFlagBits] = [
            .sixtyFour,
            .thirtyTwo,
            .sixteen,
            .eight,
            .four,
            .two,
        ]

        for sampleCount in sampleCounts {
            if supportedSampleCount.contains(sampleCount) {
                return sampleCount
            }
        }

        return .one
    }()

    internal override init(instance: Instance, handle: SharedPointer<VkPhysicalDevice_T>) throws {
        // var features11: VkPhysicalDeviceVulkan11Features = .new()
        // var features12: VkPhysicalDeviceVulkan12Features = .new()

        var features2: VkPhysicalDeviceFeatures2 = .new()

        // try withUnsafeMutablePointer(to: &features11) { features11 in
        // try withUnsafeMutablePointer(to: &features12) { features12 in
        // features11.pointee.pNext = UnsafeMutableRawPointer(features12)
        // features2.pNext = UnsafeMutableRawPointer(features11)

        try withUnsafeMutablePointer(to: &features2) { features2 in
            try vulkanInvoke {
                vkGetPhysicalDeviceFeatures2(handle.pointer, features2)
            }
        }

        // features2.pNext = nil
        // features11.pointee.pNext = nil
        // }
        // }

        // self.features11 = features11
        // self.features12 = features12
        self.features2 = features2
        features = features2.features

        properties = try handle.loadData(using: vkGetPhysicalDeviceProperties)
        queueFamiliesProperties = try handle.loadDataArray(using: vkGetPhysicalDeviceQueueFamilyProperties)
        memoryProperties = try handle.loadData(using: vkGetPhysicalDeviceMemoryProperties)

        var deviceExtensionCount: CUnsignedInt = 0
        try vulkanInvoke {
            vkEnumerateDeviceExtensionProperties(handle.pointer, nil, &deviceExtensionCount, nil)
        }

        let deviceExtensionsBuffer = SharedPointer<VkExtensionProperties>.allocate(capacity: Int(deviceExtensionCount))

        try vulkanInvoke {
            vkEnumerateDeviceExtensionProperties(handle.pointer, nil, &deviceExtensionCount, deviceExtensionsBuffer.pointer)
        }

        extensionProperties = UnsafeBufferPointer(start: deviceExtensionsBuffer.pointer, count: Int(deviceExtensionCount)).map { $0 }

        // smumriak: when running under renderdoc this thing contains duplicate values. not sure if it's because i have validation layers enabled in code or not
        supportedExtensionsVersions = extensionProperties
            .compactMap {
                $0.nameVersion() as (name: DeviceExtension, version: UInt)?
            }
            .reduce([:]) { accumulator, element in
                if let existing = accumulator[element.name], existing >= element.version {
                    return accumulator
                }
                var mutableAccumulator = accumulator
                mutableAccumulator[element.name] = element.version
                return mutableAccumulator
            }

        deviceType = properties.deviceType

        try super.init(instance: instance, handle: handle)
    }

    #if os(Linux)
        public func createXlibSurface(display: UnsafeMutablePointer<Display>, window: Window, desiredFormat: VkFormat = .b8g8r8a8SRGB, desiredColorSpace: VkColorSpaceKHR = .srgbNonlinear) throws -> Surface {
            let desiredSurfaceFormat = VkSurfaceFormatKHR(format: desiredFormat, colorSpace: desiredColorSpace)
            return try Surface(physicalDevice: self, display: display, window: window, desiredFormat: desiredSurfaceFormat)
        }
    #endif

    public func queueFamilyIndex(for queueType: VkQueueFlagBits) -> Array<VkQueueFamilyProperties>.Index? {
        let queueFamiliesPropertiesEnumerated = queueFamiliesProperties.enumerated()

        // try to find dedicated Compute queue family that is not Graphics
        if queueType.contains(.compute) && queueType.isDisjoint(with: .graphics) {
            for pair in queueFamiliesPropertiesEnumerated {
                if pair.element.type.contains(queueType) && pair.element.type.isDisjoint(with: .graphics) {
                    return pair.offset
                }
            }
        }

        // try to find dedicated Transfer queue family that is not Graphics
        if queueType.contains(.transfer) && queueType.isDisjoint(with: .graphics) {
            for pair in queueFamiliesPropertiesEnumerated {
                if pair.element.type.contains(queueType) && pair.element.type.isDisjoint(with: .graphics) {
                    return pair.offset
                }
            }
        }

        // for all other types find first that supports all needed types
        for pair in queueFamiliesPropertiesEnumerated {
            if pair.element.type.contains(queueType) {
                return pair.offset
            }
        }

        return nil
    }
}

extension PhysicalDevice: Comparable {
    public static func < (lhs: PhysicalDevice, rhs: PhysicalDevice) -> Bool {
        return lhs.renderingPerformanceScore < rhs.renderingPerformanceScore
    }

    public static func == (lhs: PhysicalDevice, rhs: PhysicalDevice) -> Bool {
        lhs.handle == rhs.handle
    }
}
