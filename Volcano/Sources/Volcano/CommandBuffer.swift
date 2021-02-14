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

    public override init(device: Device, handlePointer: SmartPointer<VkCommandBuffer_T>) throws {
        self.fence = try Fence(device: device)

        try super.init(device: device, handlePointer: handlePointer)
    }

    public func record(using body: () throws -> ()) throws {
        try begin()
        try body()
        try end()
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

    public func begin(renderPass: RenderPass, framebuffer: Framebuffer, renderArea: VkRect2D, clearValues: [VkClearValue] = [], subpassContents: VkSubpassContents = .inline) throws {
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

    public func bind(pipeline: Pipeline, bindPoint: VkPipelineBindPoint) throws {
        try vulkanInvoke {
            vkCmdBindPipeline(handle, bindPoint, pipeline.handle)
        }
    }

    public func bind(pipeline: GraphicsPipeline) throws {
        try bind(pipeline: pipeline, bindPoint: .graphics)
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

    public func bind(vertexBuffers: [Buffer], offsets: [VkDeviceSize] = []) throws {
        let vertexBuffersOffsets: [VkDeviceSize]

        if offsets.isEmpty {
            vertexBuffersOffsets = Array<VkDeviceSize>(repeatElement(0, count: vertexBuffers.count))
        } else {
            assert(vertexBuffers.count == offsets.count, "Offstes count should be the same as vertex buffers count")
            
            vertexBuffersOffsets = offsets
        }

        try vertexBuffers.map { $0.handle as VkBuffer? }
            .withUnsafeBufferPointer { vertexBuffers in
                try vertexBuffersOffsets.withUnsafeBufferPointer { vertexBuffersOffsets in
                    try vulkanInvoke {
                        vkCmdBindVertexBuffers(handle, 0, CUnsignedInt(vertexBuffers.count), vertexBuffers.baseAddress!, vertexBuffersOffsets.baseAddress!)
                    }
                }
            }
    }
    
    public func bind(indexBuffer: Buffer, offset: VkDeviceSize = 0, type: VkIndexType) throws {
        vkCmdBindIndexBuffer(handle, indexBuffer.handle, offset, type)
    }

    public func bind(descriptorSets: [VkDescriptorSet?], for pipeline: GraphicsPipeline) throws {
        try bind(descriptorSets: descriptorSets, bindPoint: .graphics, pipelineLayout: pipeline.layout)
    }

    public func bind(descriptorSets: [VkDescriptorSet?], bindPoint: VkPipelineBindPoint, pipelineLayout: SmartPointer<VkPipelineLayout_T>) throws {
        try descriptorSets.withUnsafeBufferPointer { descriptorSets in
            try vulkanInvoke {
                vkCmdBindDescriptorSets(handle, bindPoint, pipelineLayout.pointer, 0, CUnsignedInt(descriptorSets.count), descriptorSets.baseAddress!, 0, nil)
            }
        }
    }

    public func draw(vertexCount: Int = 0, firstVertex: Int = 0, instanceCount: Int = 1, firstInstance: Int = 0) throws {
        try vulkanInvoke {
            vkCmdDraw(handle,
                      CUnsignedInt(vertexCount),
                      CUnsignedInt(instanceCount),
                      CUnsignedInt(firstVertex),
                      CUnsignedInt(firstInstance))
        }
    }

    public func drawIndexed(indexCount: CUnsignedInt, instanceCount: CUnsignedInt = 1, firstIndex: CUnsignedInt = 0, vertexOffset: CInt = 0, firstInstance: CUnsignedInt = 0) throws {
        try vulkanInvoke {
            vkCmdDrawIndexed(handle, indexCount, instanceCount, firstIndex, vertexOffset, firstInstance)
        }
    }

    public func copyBuffer(from sourceBuffer: Buffer, to destinationBuffer: Buffer, sourceOffset: VkDeviceSize = 0, destinationOffset: VkDeviceSize = 0, size: VkDeviceSize? = nil) throws {
        let remainingDestinationSize = destinationBuffer.size - destinationOffset
        let remainingSourceSize = sourceBuffer.size - sourceOffset

        assert((size ?? sourceBuffer.size) - sourceOffset <= remainingSourceSize, "Requested copy size is bigger than source buffer size. In release mode only the part that fits will be copied")
        
        let sourceSize = min(size ?? sourceBuffer.size, remainingSourceSize)

        assert(sourceSize <= remainingDestinationSize, "Not enough memory size to copy buffer. In release mode only the part that fits will be copied")

        let copySize = min(sourceSize, remainingDestinationSize)

        var bufferCopyRegion = VkBufferCopy(srcOffset: sourceOffset, dstOffset: destinationOffset, size: copySize)
        try vulkanInvoke {
            vkCmdCopyBuffer(handle, sourceBuffer.handle, destinationBuffer.handle, 1, &bufferCopyRegion)
        }
    }
}
