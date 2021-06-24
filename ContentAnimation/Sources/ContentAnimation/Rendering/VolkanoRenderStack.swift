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

public enum VolcanoRenderStackError: Error {
    case noDiscreteGPU
    case noPresentationQueueFound
    case noGraphicsQueueFound
    case noTransferQueueFound
}

public final class VolcanoRenderStack {
    public struct Queues {
        public let graphics: Queue
        public let transfer: Queue
    }

    public fileprivate(set) var instance: Instance
    public fileprivate(set) var physicalDevice: PhysicalDevice
    public fileprivate(set) var device: Device
    public fileprivate(set) var queues: Queues

    public static var global: VolcanoRenderStack! = nil
    
    public static func setupGlobalStack() throws {
        guard Self.global == nil else {
            fatalError("Global vulkan render stack has already been set up")
        }

        Self.global = try VolcanoRenderStack()
    }

    internal init() throws {
        instance = Instance()

        guard let physicalDevice = instance.discreteGPUDevice else {
            throw VolcanoRenderStackError.noDiscreteGPU
        }

        self.physicalDevice = physicalDevice

        let graphicsQueueRequest = QueueRequest(type: .graphics)
        let transferQueueRequest = QueueRequest(type: .transfer)

        let device = try Device(physicalDevice: physicalDevice, queueRequests: [graphicsQueueRequest, transferQueueRequest])

        guard let graphicsQueue = device.allQueues.first(where: { $0.type.contains(.graphics) }) else {
            throw VolcanoRenderStackError.noGraphicsQueueFound
        }

        guard let transferQueue = device.allQueues.first(where: { $0.type.contains(.transfer) }) else {
            throw VolcanoRenderStackError.noTransferQueueFound
        }
        
        self.device = device
        self.queues = Queues(graphics: graphicsQueue, transfer: transferQueue)
    }
}
