//
//  CommandBuffer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import TinyFoundation
import CVulkan

public final class CommandBuffer: VulkanDeviceEntity<SmartPointer<VkCommandBuffer_T>> {
    public let fence: Fence

    public init(commandPool: CommandPool, level: VkCommandBufferLevel = .VK_COMMAND_BUFFER_LEVEL_PRIMARY) throws {
        let device = commandPool.device

        var info = VkCommandBufferAllocateInfo()
        info.sType = .commandBufferAllocateInfo
        info.level = level
        info.commandPool = commandPool.handle
        info.commandBufferCount = 1

        let handle = try device.allocate(info: &info, using: vkAllocateCommandBuffers)
        let handlePointer = SmartPointer(with: handle) { [unowned device, unowned commandPool] in
            var mutablePointer: VkCommandBuffer? = $0
            vkFreeCommandBuffers(device.handle, commandPool.handle, 1, &mutablePointer)
        }

        self.fence = try Fence(device: device)

        try super.init(device: commandPool.device, handlePointer: handlePointer)
    }

    public func begin(flags: VkCommandBufferUsageFlagBits = []) throws {
        var info = VkCommandBufferBeginInfo()
        info.sType = .commandBufferBeginInfo
        info.pNext = nil
        info.flags = flags.rawValue
        info.pInheritanceInfo = nil

        try vulkanInvoke {
            vkBeginCommandBuffer(handle, &info)
        }
    }

    public func end() throws {
        try vulkanInvoke {
            vkEndCommandBuffer(handle)
        }
    }

    public func beginRenderPass(_ renderPass: RenderPass, framebuffer: Framebuffer, renderArea: VkRect2D, clearValues: [VkClearValue] = [], subpassContents: VkSubpassContents = .inline) throws {
        try clearValues.withUnsafeBufferPointer { clearValues in
            var renderPassBeginInfo = VkRenderPassBeginInfo()
            renderPassBeginInfo.sType = .renderPassBeginInfo
            renderPassBeginInfo.renderPass = renderPass.handle
            renderPassBeginInfo.framebuffer = framebuffer.handle
            renderPassBeginInfo.renderArea = renderArea
            renderPassBeginInfo.clearValueCount = CUnsignedInt(clearValues.count)
            renderPassBeginInfo.pClearValues = clearValues.baseAddress!

            try vulkanInvoke {
                vkCmdBeginRenderPass(handle, &renderPassBeginInfo, subpassContents)
            }
        }
    }

    public func endRenderPass() throws {
        try vulkanInvoke {
            vkCmdEndRenderPass(handle)
        }
    }

    public func bind(pipeline: SmartPointer<VkPipeline_T>, bindPoint: VkPipelineBindPoint = .graphics) throws {
        try vulkanInvoke {
            vkCmdBindPipeline(handle, bindPoint, pipeline.pointer)
        }
    }

    public func setViewports(_ viewports: [VkViewport]) throws {
        try viewports.withUnsafeBufferPointer { viewports in
            try vulkanInvoke {
                vkCmdSetViewport(handle, 0, CUnsignedInt(viewports.count), viewports.baseAddress!)
            }
        }
    }

    public func setScissors(_ scissors: [VkRect2D]) throws {
        try scissors.withUnsafeBufferPointer { scissors in
            try vulkanInvoke {
                vkCmdSetScissor(handle, 0, CUnsignedInt(scissors.count), scissors.baseAddress!)
            }
        }
    }

    public func draw(vertexCount: Int = 0, firstVertex: Int = 0, instanceCount: Int = 0, firstInstance: Int = 0) throws {
        try vulkanInvoke {
            vkCmdDraw(handle,
                      CUnsignedInt(vertexCount),
                      CUnsignedInt(instanceCount),
                      CUnsignedInt(firstVertex),
                      CUnsignedInt(firstInstance))
        }
    }
}
