//
//  Queue.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import TinyFoundation
import CVulkan

public final class Queue: HandleStorage<SmartPointer<VkQueue_T>> {
    public internal(set) unowned var device: Device
    public let familyIndex: Int
    public let queueIndex: Int
    public let type: VkQueueFlagBits

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
                       waitStages: [VkPipelineStageFlags] = [],
                       fence: Fence? = nil) throws {
        let commandBuffersHandles: [VkCommandBuffer?] = commandBuffers.map { $0.handle }
        let waitSemaphoresHandles: [VkSemaphore?] = waitSemaphores.map { $0.handle }
        let signalSemaphoresHandles: [VkSemaphore?] = signalSemaphores.map { $0.handle }

        try waitStages.withUnsafeBufferPointer { waitStagesPointer in
            try signalSemaphoresHandles.withUnsafeBufferPointer { signalSemaphoresPointer in
                try waitSemaphoresHandles.withUnsafeBufferPointer { waitSemaphoresPointer in
                    try commandBuffersHandles.withUnsafeBufferPointer { commandBufferPointer in
                        var submitInfo = VkSubmitInfo()
                        submitInfo.sType = .submitInfo

                        submitInfo.waitSemaphoreCount = CUnsignedInt(waitSemaphoresPointer.count)
                        submitInfo.pWaitSemaphores = waitSemaphoresPointer.baseAddress!

                        submitInfo.signalSemaphoreCount = CUnsignedInt(signalSemaphoresPointer.count)
                        submitInfo.pSignalSemaphores = signalSemaphoresPointer.baseAddress!

                        submitInfo.pWaitDstStageMask = waitStagesPointer.baseAddress!

                        submitInfo.commandBufferCount = CUnsignedInt(commandBufferPointer.count)
                        submitInfo.pCommandBuffers = commandBufferPointer.baseAddress!
                        try vulkanInvoke {
                            vkQueueSubmit(handle, 1, &submitInfo, fence?.handle)
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
                    presentInfo.sType = .presentInfoKHR

                    presentInfo.waitSemaphoreCount = CUnsignedInt(waitSemaphoresPointer.count)
                    presentInfo.pWaitSemaphores = waitSemaphoresPointer.baseAddress

                    presentInfo.swapchainCount = CUnsignedInt(swapchainsPointer.count)
                    presentInfo.pSwapchains = swapchainsPointer.baseAddress!

                    presentInfo.pImageIndices = imageIndicesPointer.baseAddress!
                    presentInfo.pResults = nil

                    try vulkanInvoke {
                        device.vkQueuePresentKHR(handle, &presentInfo)
                    }
                }
            }
        }
    }

    public func oneShot(in commandPool: CommandPool, wait: Bool = true, _ body: (_ commandBuffer: CommandBuffer) throws -> ()) throws {
        let commandBuffer = try commandPool.createCommandBuffer()

        let fence: Fence? = wait ? commandBuffer.fence : nil

        try fence?.reset()

        try commandBuffer.begin(flags: .oneTimeSubmit)

        try body(commandBuffer)

        try commandBuffer.end()

        try submit(commandBuffers: [commandBuffer], fence: fence)
        
        try fence?.wait()
    }
}

public extension Array where Element == Queue {
    var familyIndices: [CUnsignedInt] {
        return Array<CUnsignedInt>(Set(map { CUnsignedInt($0.familyIndex) }))
    }
}