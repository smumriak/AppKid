//
//  CommandBuffer.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.05.2020.
//

import TinyFoundation
import CVulkan

public final class CommandBuffer: DeviceEntity<SharedPointer<VkCommandBuffer_T>> {
    public func record(using body: () throws -> ()) throws {
        try begin()
        try body()
        try end()
    }

    public func record(using body: (CommandBuffer) throws -> ()) throws {
        try begin()
        try body(self)
        try end()
    }

    public func reset(flags: VkCommandBufferResetFlagBits = []) throws {
        try vulkanInvoke {
            vkResetCommandBuffer(pointer, flags.rawValue)
        }
    }

    public func begin(flags: VkCommandBufferUsageFlagBits = []) throws {
        var info = VkCommandBufferBeginInfo.new()
        info.pNext = nil
        info.flags = flags.rawValue
        info.pInheritanceInfo = nil

        try vulkanInvoke {
            vkBeginCommandBuffer(pointer, &info)
        }
    }

    public func end() throws {
        try vulkanInvoke {
            vkEndCommandBuffer(pointer)
        }
    }

    public func begin(renderPass: RenderPass, framebuffer: Framebuffer, renderArea: VkRect2D, clearValues: [VkClearValue] = [], subpassContents: VkSubpassContents = .inline) throws {
        try clearValues.withUnsafeBufferPointer { clearValues in
            var renderPassBeginInfo = VkRenderPassBeginInfo.new()
            renderPassBeginInfo.renderPass = renderPass.pointer
            renderPassBeginInfo.framebuffer = framebuffer.pointer
            renderPassBeginInfo.renderArea = renderArea
            renderPassBeginInfo.clearValueCount = CUnsignedInt(clearValues.count)
            renderPassBeginInfo.pClearValues = clearValues.baseAddress!

            try vulkanInvoke {
                vkCmdBeginRenderPass(pointer, &renderPassBeginInfo, subpassContents)
            }
        }
    }

    public func endRenderPass() throws {
        try vulkanInvoke {
            vkCmdEndRenderPass(pointer)
        }
    }

    public func bind(pipeline: Pipeline, bindPoint: VkPipelineBindPoint) throws {
        try vulkanInvoke {
            vkCmdBindPipeline(pointer, bindPoint, pipeline.pointer)
        }
    }

    public func bind(pipeline: GraphicsPipeline) throws {
        try bind(pipeline: pipeline, bindPoint: .graphics)
    }

    public func setViewports(_ viewports: [VkViewport]) throws {
        try viewports.withUnsafeBufferPointer { viewports in
            try vulkanInvoke {
                vkCmdSetViewport(pointer, 0, CUnsignedInt(viewports.count), viewports.baseAddress!)
            }
        }
    }

    public func setScissors(_ scissors: [VkRect2D]) throws {
        try scissors.withUnsafeBufferPointer { scissors in
            try vulkanInvoke {
                vkCmdSetScissor(pointer, 0, CUnsignedInt(scissors.count), scissors.baseAddress!)
            }
        }
    }

    @inlinable @inline(__always)
    public func bind(vertexBuffer buffer: Buffer, offset: VkDeviceSize = 0, firstBinding: CUnsignedInt = 0) throws {
        try bind(vertexBuffers: [buffer], offsets: [offset], firstBinding: firstBinding)
    }

    public func bind(vertexBuffers buffers: [Buffer], offsets inoutOffsets: [VkDeviceSize] = [], firstBinding: CUnsignedInt = 0) throws {
        let count = buffers.count
        let offsets: [VkDeviceSize]

        if inoutOffsets.isEmpty {
            offsets = Array<VkDeviceSize>(repeatElement(0, count: count))
        } else {
            assert(buffers.count == inoutOffsets.count, "Offstes count should be the same as vertex buffers count")
            
            offsets = inoutOffsets
        }

        try buffers.map { $0.pointer as VkBuffer? }
            .withUnsafeBufferPointer { buffers in
                try offsets.withUnsafeBufferPointer { offsets in
                    try vulkanInvoke {
                        vkCmdBindVertexBuffers(pointer, firstBinding, CUnsignedInt(count), buffers.baseAddress!, offsets.baseAddress!)
                    }
                }
            }
    }
    
    public func bind(indexBuffer: Buffer, offset: VkDeviceSize = 0, type: VkIndexType) throws {
        vkCmdBindIndexBuffer(pointer, indexBuffer.pointer, offset, type)
    }

    public func bind(descriptorSets: [DescriptorSet], for pipeline: GraphicsPipeline) throws {
        try bind(descriptorSets: descriptorSets, bindPoint: .graphics, pipelineLayout: pipeline.layout)
    }

    public func bind(descriptorSets: [DescriptorSet], bindPoint: VkPipelineBindPoint, pipelineLayout: SharedPointer<VkPipelineLayout_T>) throws {
        try descriptorSets.optionalHandles()
            .withUnsafeBufferPointer { descriptorSets in
                try vulkanInvoke {
                    vkCmdBindDescriptorSets(pointer, bindPoint, pipelineLayout.pointer, 0, CUnsignedInt(descriptorSets.count), descriptorSets.baseAddress!, 0, nil)
                }
            }
    }

    public func bind(descriptorSets: [VkDescriptorSet], for pipeline: GraphicsPipeline) throws {
        try bind(descriptorSets: descriptorSets, bindPoint: .graphics, pipelineLayout: pipeline.layout)
    }

    public func bind(descriptorSets: [VkDescriptorSet], bindPoint: VkPipelineBindPoint, pipelineLayout: SharedPointer<VkPipelineLayout_T>) throws {
        try descriptorSets.map { $0 as VkDescriptorSet? }
            .withUnsafeBufferPointer { descriptorSets in
                try vulkanInvoke {
                    vkCmdBindDescriptorSets(pointer, bindPoint, pipelineLayout.pointer, 0, CUnsignedInt(descriptorSets.count), descriptorSets.baseAddress!, 0, nil)
                }
            }
    }

    public func draw(vertexCount: Int, firstVertex: Int = 0, instanceCount: Int = 1, firstInstance: Int = 0) throws {
        try vulkanInvoke {
            vkCmdDraw(pointer,
                      CUnsignedInt(vertexCount),
                      CUnsignedInt(instanceCount),
                      CUnsignedInt(firstVertex),
                      CUnsignedInt(firstInstance))
        }
    }

    public func drawIndexed(indexCount: CUnsignedInt, instanceCount: CUnsignedInt = 1, firstIndex: CUnsignedInt = 0, vertexOffset: CInt = 0, firstInstance: CUnsignedInt = 0) throws {
        try vulkanInvoke {
            vkCmdDrawIndexed(pointer, indexCount, instanceCount, firstIndex, vertexOffset, firstInstance)
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
            vkCmdCopyBuffer(pointer, sourceBuffer.pointer, destinationBuffer.pointer, 1, &bufferCopyRegion)
        }
    }
    
    public func copyBuffer(from buffer: Buffer, to texture: Texture, bufferOffset: VkDeviceSize = 0, mipLevel: CUnsignedInt = 0, texelsPerRow: CUnsignedInt? = nil, height: CUnsignedInt? = nil, textureRect: VkRect3D? = nil, copiedLayersRange: Range<CUnsignedInt> = 0..<1) throws {
        let textureRect = textureRect ?? VkRect3D(offset: .zero, extent: texture.extent)
        let texelsPerRow: CUnsignedInt = texelsPerRow ?? 0
        let height: CUnsignedInt = height ?? 0

        assert(texelsPerRow == 0 || texelsPerRow >= textureRect.width, "According to vulkan spec the bytes per row has to be either 0 or greater than equal to texture's width")
        assert(height == 0 || height >= textureRect.height, "According to vulkan spec the height has to be either 0 or greater than equal to texture's height")

        let imageSubresource = VkImageSubresourceLayers(aspectMask: texture.imageView.aspect.rawValue, mipLevel: mipLevel, baseArrayLayer: copiedLayersRange.startIndex, layerCount: CUnsignedInt(copiedLayersRange.count))
        var bufferCopyRegion = VkBufferImageCopy(bufferOffset: bufferOffset, bufferRowLength: texelsPerRow, bufferImageHeight: height, imageSubresource: imageSubresource, imageOffset: textureRect.offset, imageExtent: textureRect.extent)
        
        try vulkanInvoke {
            vkCmdCopyBufferToImage(pointer, buffer.pointer, texture.image.pointer, texture.layout, 1, &bufferCopyRegion)
        }
    }

    @_spi(AppKid) public func performPredefinedLayoutTransition(for texture: Texture, newLayout: VkImageLayout) throws {
        var barrier = VkImageMemoryBarrier.new()

        var sourceAccessMask: VkAccessFlagBits = []
        var destinationAccessMask: VkAccessFlagBits = []

        var sourceStage: VkPipelineStageFlagBits = []
        var destinationStage: VkPipelineStageFlagBits = []

        let oldLayout = texture.layout

        switch (oldLayout, newLayout) {
            case (.undefined, .transferDestinationOptimal):
                destinationAccessMask.formUnion(.transferWrite)

                sourceStage.formUnion(.topOfPipe)
                destinationStage.formUnion(.transfer)

            case (.transferDestinationOptimal, .shaderReadOnlyOptimal):
                sourceAccessMask.formUnion(.transferWrite)
                destinationAccessMask.formUnion(.shaderRead)

                sourceStage.formUnion(.transfer)
                destinationStage.formUnion(.fragmentShader)

            case (.shaderReadOnlyOptimal, .transferDestinationOptimal):
                sourceAccessMask.formUnion(.shaderRead)
                destinationAccessMask.formUnion(.transferWrite)

                sourceStage.formUnion(.fragmentShader)
                destinationStage.formUnion(.transfer)

            default:
                assertionFailure("Volcano: Unsupported layout transition from \(oldLayout) to \(newLayout)")
        }

        barrier.srcAccessMask = sourceAccessMask.rawValue
        barrier.dstAccessMask = destinationAccessMask.rawValue

        barrier.oldLayout = oldLayout
        barrier.newLayout = newLayout

        barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED
        barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED

        barrier.subresourceRange = texture.imageView.subresourceRange

        barrier.image = texture.image.pointer

        try vulkanInvoke {
            vkCmdPipelineBarrier(pointer,
                                 sourceStage.rawValue, destinationStage.rawValue,
                                 0,
                                 0, nil, // memory barriers
                                 0, nil, // buffer memory barriers
                                 1, &barrier) // image memory barriers
        }

        texture.setLayout(newLayout)
    }
}
