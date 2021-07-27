//
//  Queue.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class Queue: HandleStorage<SmartPointer<VkQueue_T>> {
    public internal(set) unowned var device: Device
    public let familyIndex: Int
    public let queueIndex: Int
    public let type: VkQueueFlagBits

    private let lock = NSRecursiveLock()

    public init(device: Device, familyIndex: Int, queueIndex: Int, type: VkQueueFlagBits) throws {
        self.device = device
        self.familyIndex = familyIndex
        self.queueIndex = queueIndex
        self.type = type

        var handle: VkQueue?
        try vulkanInvoke {
            vkGetDeviceQueue(device.handle, CUnsignedInt(familyIndex), CUnsignedInt(queueIndex), &handle)
        }

        super.init(handlePointer: SmartPointer(with: handle!))
    }

    public func waitForIdle() throws {
        try vulkanInvoke {
            vkQueueWaitIdle(handle)
        }
    }

    public func submit(commandBuffers: [CommandBuffer],
                       waitSemaphores: [Volcano.Semaphore] = [],
                       signalSemaphores: [Volcano.Semaphore] = [],
                       waitStages: [VkPipelineStageFlagBits] = [],
                       fence: Fence? = nil) throws {
        assert(waitSemaphores.count == waitStages.count)

        var descriptor = SubmitDescriptor(commandBuffers: commandBuffers, fence: fence)
        try zip(waitSemaphores, waitStages).forEach {
            try descriptor.add(WaitDescriptor(semaphore: $0.0, waitStages: $0.1))
        }

        try signalSemaphores.forEach {
            try descriptor.add(SignalDescriptor(semaphore: $0))
        }

        try submit(with: descriptor)
    }

    public func submit(with descriptor: SubmitDescriptor) throws {
        try descriptor.commandBuffers.optionalPointers().withUnsafeBufferPointer { commandBuffers in
            try descriptor.waitSemaphores.optionalPointers().withUnsafeBufferPointer { waitSemaphores in
                try descriptor.waitSemaphoreValues.withUnsafeBufferPointer { waitSemaphoreValues in
                    try descriptor.waitStages.withUnsafeBufferPointer { waitStages in
                        try descriptor.signalSemaphores.optionalPointers().withUnsafeBufferPointer { signalSemaphores in
                            try descriptor.signalSemaphoreValues.withUnsafeBufferPointer { signalSemaphoreValues in
                                var info: VkSubmitInfo = .new()

                                info.waitSemaphoreCount = CUnsignedInt(waitSemaphores.count)
                                info.pWaitSemaphores = waitSemaphores.baseAddress!

                                info.signalSemaphoreCount = CUnsignedInt(signalSemaphores.count)
                                info.pSignalSemaphores = signalSemaphores.baseAddress!

                                info.pWaitDstStageMask = waitStages.baseAddress!

                                info.commandBufferCount = CUnsignedInt(commandBuffers.count)
                                info.pCommandBuffers = commandBuffers.baseAddress!

                                let chain = VulkanStructureChain(root: info)

                                if descriptor.hasTimeline {
                                    var timelineInfo: VkTimelineSemaphoreSubmitInfo = .new()
                                    timelineInfo.waitSemaphoreValueCount = CUnsignedInt(waitSemaphoreValues.count)
                                    timelineInfo.pWaitSemaphoreValues = waitSemaphoreValues.baseAddress!
                                    timelineInfo.signalSemaphoreValueCount = CUnsignedInt(signalSemaphoreValues.count)
                                    timelineInfo.pSignalSemaphoreValues = signalSemaphoreValues.baseAddress!

                                    chain.add(chainElement: timelineInfo)
                                }

                                lock.lock()
                                defer { lock.unlock() }

                                try chain.withUnsafeChainPointer { info in
                                    try vulkanInvoke {
                                        vkQueueSubmit(handle, 1, info, descriptor.fence?.handle)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public func present(swapchains: [Swapchain],
                        waitSemaphores: [Volcano.Semaphore] = [],
                        imageIndices: [CUnsignedInt]) throws {
        let swapchainsHandles: [VkSwapchainKHR?] = swapchains.map { $0.handle }
        let waitSemaphoresHandles: [VkSemaphore?] = waitSemaphores.map { $0.handle }

        try imageIndices.withUnsafeBufferPointer { imageIndicesPointer in
            try waitSemaphoresHandles.withUnsafeBufferPointer { waitSemaphoresPointer in
                try swapchainsHandles.withUnsafeBufferPointer { swapchainsPointer in
                    var presentInfo = VkPresentInfoKHR()
                    presentInfo.sType = .presentInfoKhr

                    presentInfo.waitSemaphoreCount = CUnsignedInt(waitSemaphoresPointer.count)
                    presentInfo.pWaitSemaphores = waitSemaphoresPointer.baseAddress

                    presentInfo.swapchainCount = CUnsignedInt(swapchainsPointer.count)
                    presentInfo.pSwapchains = swapchainsPointer.baseAddress!

                    presentInfo.pImageIndices = imageIndicesPointer.baseAddress!
                    presentInfo.pResults = nil

                    lock.lock()
                    defer { lock.unlock() }
        
                    try vulkanInvoke {
                        device.vkQueuePresentKHR(handle, &presentInfo)
                    }
                }
            }
        }
    }

    public func oneShot(in commandPool: CommandPool, wait: Bool = true, _ body: (_ commandBuffer: CommandBuffer) throws -> ()) throws {
        let commandBuffer = try commandPool.createCommandBuffer()

        let fence: Fence? = wait ? try Fence(device: device) : nil

        try fence?.reset()

        try commandBuffer.begin(flags: .oneTimeSubmit)

        try body(commandBuffer)

        try commandBuffer.end()

        try submit(commandBuffers: [commandBuffer], fence: fence)
        
        try fence?.wait()
    }

    public func createCommandPool(flags: VkCommandPoolCreateFlagBits = .resetCommandBuffer) throws -> CommandPool {
        try CommandPool(device: device, queue: self, flags: flags)
    }
}

public extension Array where Element == Queue {
    var familyIndices: [CUnsignedInt] {
        return Array<CUnsignedInt>(Set(map { CUnsignedInt($0.familyIndex) }))
    }
}

public struct WaitDescriptor {
    let semaphore: AbstractSemaphore
    let value: UInt64
    let waitStages: VkPipelineStageFlagBits

    public init(semaphore: Semaphore, waitStages: VkPipelineStageFlagBits) throws {
        self.semaphore = semaphore
        self.value = 0
        self.waitStages = waitStages
    }

    public init(timelineSemaphore: TimelineSemaphore, value: UInt64? = nil, waitStages: VkPipelineStageFlagBits) throws {
        self.semaphore = timelineSemaphore
        self.value = try value ?? (timelineSemaphore.value + 1)
        self.waitStages = waitStages
    }
}

public struct SignalDescriptor {
    let semaphore: AbstractSemaphore
    let value: UInt64

    public init(semaphore: Semaphore) throws {
        self.semaphore = semaphore
        self.value = 0
    }

    public init(timelineSemaphore: TimelineSemaphore, value: UInt64? = nil) throws {
        self.semaphore = timelineSemaphore
        self.value = try value ?? (timelineSemaphore.value + 1)
    }
}

public struct SubmitDescriptor {
    internal let commandBuffers: [CommandBuffer]
    internal var waitSemaphores: [AbstractSemaphore] = []
    internal var waitSemaphoreValues: [UInt64] = []
    internal var waitStages: [VkPipelineStageFlags] = []

    internal var signalSemaphores: [AbstractSemaphore] = []
    internal var signalSemaphoreValues: [UInt64] = []
    internal let fence: Fence?

    internal var hasTimeline: Bool = false

    public init(commandBuffers: [CommandBuffer], fence: Fence? = nil) {
        assert(commandBuffers.count > 0)

        self.commandBuffers = commandBuffers
        self.fence = fence
    }

    public mutating func add(_ descriptor: WaitDescriptor) {
        waitSemaphores.append(descriptor.semaphore)
        waitSemaphoreValues.append(descriptor.value)
        waitStages.append(descriptor.waitStages.rawValue)

        if descriptor.value != 0 {
            hasTimeline = true
        }
    }

    public mutating func add(_ descriptor: SignalDescriptor) {
        signalSemaphores.append(descriptor.semaphore)
        signalSemaphoreValues.append(descriptor.value)

        if descriptor.value != 0 {
            hasTimeline = true
        }
    }
}
