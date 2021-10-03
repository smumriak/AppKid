//
//  VolcanoRenderStack.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 21.08.2020.
//

import Foundation
import Volcano
import TinyFoundation
import CVulkan
import SwiftVMA

@_spi(AppKid) public final class VolcanoRenderStack {
    @_spi(AppKid) public enum Error: Swift.Error {
        case noDiscreteGPU
        case noPresentationQueueFound
        case noGraphicsQueueFound
        case noTransferQueueFound
    }

    public struct Queues {
        public let graphics: Queue
        public let transfer: Queue
    }

    public fileprivate(set) var instance: Instance
    public fileprivate(set) var physicalDevice: PhysicalDevice
    public fileprivate(set) var device: Device
    public fileprivate(set) var queues: Queues
    public let semaphoreWatcher: SemaphoreWatcher

    public static var global: VolcanoRenderStack! = nil
    
    public static func setupGlobalStack() throws {
        guard Self.global == nil else {
            fatalError("Global vulkan render stack has already been set up")
        }

        Self.global = try VolcanoRenderStack()
    }

    public func cleanup() throws {
        try semaphoreWatcher.runLoop.stop()
    }

    internal init() throws {
        var extensions: Set<VulkanExtensionName> = [.surface]
        #if os(Linux)
            extensions.formUnion([.xlibSurface, .xcbSurface, .waylandSurface])
        #endif
        instance = Instance(extensions: extensions)

        let physicalDevice = instance.physicalDevices.first {
            $0.features.samplerAnisotropy.bool == true
        }

        guard let physicalDevice = physicalDevice else {
            throw Error.noDiscreteGPU
        }

        self.physicalDevice = physicalDevice

        let graphicsQueueRequest = QueueRequest(type: .graphics)
        let transferQueueRequest = QueueRequest(type: .transfer)

        let queueRequests = [graphicsQueueRequest, transferQueueRequest]

        let vulkanExtensions: Set<VulkanExtensionName> = [.swapchain]

        let device = try Device(physicalDevice: physicalDevice, queueRequests: queueRequests, extensions: vulkanExtensions, memoryAllocatorClass: VulkanMemoryAllocator.self)

        guard let graphicsQueue = device.allQueues.first(where: { $0.type.contains(.graphics) }) else {
            throw Error.noGraphicsQueueFound
        }

        guard let transferQueue = device.allQueues.first(where: { $0.type.contains(.transfer) }) else {
            throw Error.noTransferQueueFound
        }
        
        self.device = device
        self.queues = Queues(graphics: graphicsQueue, transfer: transferQueue)
        semaphoreWatcher = try SemaphoreWatcher(device: device)
    }
}
