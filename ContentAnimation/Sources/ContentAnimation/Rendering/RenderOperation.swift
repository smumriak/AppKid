//
//  RenderOperation.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 13.04.2021.
//

import Foundation
import CoreFoundation
import CairoGraphics
import Volcano
import CVulkan
import TinyFoundation
import LayerRenderingData

internal class RenderContext {
    typealias ModelViewProjection = (model: mat4s, view: mat4s, projection: mat4s)

    let renderStack: VolcanoRenderStack
    let renderTargetsStack = SimpleStack<RenderTarget>()
    let commandBuffersStack = SimpleStack<CommandBuffer>()
    let viewportsStack = SimpleStack<VkViewport>()
    let pipelines: Pipelines
    let descriptorSetsLayouts: DescriptorSetsLayouts
    let imageFormat: VkFormat

    @inlinable @inline(__always)
    var graphicsQueue: Queue { renderStack.queues.graphics }

    @inlinable @inline(__always)
    var transferQueue: Queue { renderStack.queues.transfer }
    
    let commandPool: CommandPool
    let transferCommandPool: CommandPool

    var descriptors: [LayerRenderDescriptor] = []
    var operations: [RenderOperation] = []

    @inlinable @inline(__always)
    var renderTarget: RenderTarget { renderTargetsStack.root }

    @inlinable @inline(__always)
    var commandBuffer: CommandBuffer { commandBuffersStack.root }

    @inlinable @inline(__always)
    var viewport: VkViewport { viewportsStack.root }

    private var _vertexBuffer: Buffer? = nil

    var vertexBuffer: Buffer {
        get throws {
            if let vertexBuffer = _vertexBuffer, vertexBuffer.size == VkDeviceSize(MemoryLayout<LayerRenderDescriptor>.stride * descriptors.count) {
                return vertexBuffer
            } else {
                _vertexBuffer = try createVertexBuffer()
                return _vertexBuffer!
            }
        }
    }

    let modelViewProjectionBuffer: Buffer
    let modelViewProjectionDescriptorPool: DescriptorPool
    let modelViewProjectionDescriptorSet: DescriptorSet

    var contentsDescriptorsCount: UInt = 0
    private var contentsDescriptorsSet: [UInt: DescriptorSet] = [:]

    private var _contentsDescriptorsPool: DescriptorPool? = nil
    var contentsDescriptorsPool: DescriptorPool {
        get throws {
            if let contentsDescriptorsPool = _contentsDescriptorsPool, contentsDescriptorsPool.maxSets == contentsDescriptorsCount {
                return contentsDescriptorsPool
            } else {
                let sizes = [VkDescriptorPoolSize(type: .combinedImageSampler, descriptorCount: CUnsignedInt(contentsDescriptorsCount))]

                _contentsDescriptorsPool = try DescriptorPool(device: renderStack.device, sizes: sizes, maxSets: contentsDescriptorsCount)

                return _contentsDescriptorsPool!
            }
        }
    }

    internal let contentsTextureSampler: Sampler

    private func createVertexBuffer() throws -> Buffer {
        let bufferSize = VkDeviceSize(MemoryLayout<LayerRenderDescriptor>.stride * descriptors.count)

        let stagingBuffer = try Buffer(device: renderStack.device,
                                       size: bufferSize,
                                       usage: [.transferSource],
                                       memoryProperties: [.hostVisible, .hostCoherent],
                                       accessQueues: [graphicsQueue, transferQueue])

        try descriptors.withUnsafeBufferPointer { renderDescriptors in
            try stagingBuffer.memoryChunk.withMappedData { data, size in
                data.copyMemory(from: UnsafeRawPointer(renderDescriptors.baseAddress!), byteCount: Int(stagingBuffer.size))
            }
        }

        let vertexBuffer = try Buffer(device: renderStack.device,
                                      size: bufferSize,
                                      usage: [.vertexBuffer, .transferDestination],
                                      memoryProperties: .deviceLocal,
                                      accessQueues: [graphicsQueue, transferQueue])

        try transferQueue.oneShot(in: transferCommandPool) {
            try $0.copyBuffer(from: stagingBuffer, to: vertexBuffer)
        }

        return vertexBuffer
    }

    internal func contentsDescriptorSet(for texture: Texture, layerIndex: UInt) throws -> DescriptorSet {
        if let descriptorSet = contentsDescriptorsSet[layerIndex] {
            return descriptorSet
        }

        let descriptorSet = try contentsDescriptorsPool.allocate(with: descriptorSetsLayouts.contentsSampler)
        contentsDescriptorsSet[layerIndex] = descriptorSet

        var imageInfo = VkDescriptorImageInfo()
        imageInfo.imageLayout = .shaderReadOnlyOptimal
        imageInfo.imageView = texture.imageView.handle
        imageInfo.sampler = contentsTextureSampler.handle

        try withUnsafePointer(to: &imageInfo) { imageInfo in
            var writeInfo = VkWriteDescriptorSet()
            writeInfo.sType = .writeDescriptorSet
            writeInfo.dstSet = descriptorSet.handle
            writeInfo.dstBinding = 0
            writeInfo.dstArrayElement = 0
            writeInfo.descriptorCount = 1
            writeInfo.descriptorType = .combinedImageSampler
            writeInfo.pBufferInfo = nil
            writeInfo.pImageInfo = imageInfo
            writeInfo.pTexelBufferView = nil

            try withUnsafePointer(to: &writeInfo) { writeInfo in
                try vulkanInvoke {
                    vkUpdateDescriptorSets(renderStack.device.handle, 1, writeInfo, 0, nil)
                }
            }
        }

        return descriptorSet
    }

    init(renderStack: VolcanoRenderStack, pipelines: Pipelines, descriptorSetsLayouts: DescriptorSetsLayouts, imageFormat: VkFormat = .rgba8UNorm) throws {
        let device = renderStack.device

        self.renderStack = renderStack
        self.pipelines = pipelines
        self.descriptorSetsLayouts = descriptorSetsLayouts
        self.commandPool = try CommandPool(device: device, queue: renderStack.queues.graphics)
        self.transferCommandPool = try CommandPool(device: device, queue: renderStack.queues.transfer, flags: .transient)
        self.imageFormat = imageFormat

        modelViewProjectionBuffer = try Buffer(device: device,
                                               size: VkDeviceSize(MemoryLayout<ModelViewProjection>.size),
                                               usage: [.uniformBuffer],
                                               memoryProperties: [.hostVisible, .hostCoherent],
                                               accessQueues: [renderStack.queues.graphics, renderStack.queues.transfer])

        let sizes = [VkDescriptorPoolSize(type: .uniformBuffer, descriptorCount: 1)]
        modelViewProjectionDescriptorPool = try DescriptorPool(device: device, sizes: sizes, maxSets: 1)
        let modelViewProjectionDescriptorSet = try modelViewProjectionDescriptorPool.allocate(with: descriptorSetsLayouts.modelViewProjection)
        self.modelViewProjectionDescriptorSet = modelViewProjectionDescriptorSet

        var bufferInfo = VkDescriptorBufferInfo()
        bufferInfo.buffer = modelViewProjectionBuffer.handle
        bufferInfo.offset = 0
        bufferInfo.range = VkDeviceSize(MemoryLayout<RenderContext.ModelViewProjection>.stride)

        try withUnsafePointer(to: &bufferInfo) { bufferInfo in
            var writeInfo = VkWriteDescriptorSet()
            writeInfo.sType = .writeDescriptorSet
            writeInfo.dstSet = modelViewProjectionDescriptorSet.handle
            writeInfo.dstBinding = 0
            writeInfo.dstArrayElement = 0
            writeInfo.descriptorCount = 1
            writeInfo.descriptorType = .uniformBuffer
            writeInfo.pBufferInfo = bufferInfo
            writeInfo.pImageInfo = nil
            writeInfo.pTexelBufferView = nil

            try withUnsafePointer(to: &writeInfo) { writeInfo in
                try vulkanInvoke {
                    vkUpdateDescriptorSets(device.handle, 1, writeInfo, 0, nil)
                }
            }
        }

        contentsTextureSampler = try Sampler(device: device)
    }

    func clear() throws {
        descriptors.removeAll()
        operations.removeAll()
        _vertexBuffer = nil
        _contentsDescriptorsPool = nil
        contentsDescriptorsSet.removeAll()
    }

    func performOperations() throws {
        try operations.forEach { try $0.perform(in: self) }
    }

    func add(_ operation: RenderOperation) {
        operations.append(operation)
    }

    func add(_ operations: [RenderOperation]) {
        self.operations.append(contentsOf: operations)
    }
}

extension RenderContext {
    struct Pipelines {
        let background: GraphicsPipeline
        let border: GraphicsPipeline
        let contents: GraphicsPipeline
    }
}

internal class RenderOperation {
    func perform(in context: RenderContext) throws {}

    @inlinable @inline(__always)
    static func background() -> RenderOperation {
        return BackgroundRenderOperation()
    }

    @inlinable @inline(__always)
    static func border() -> RenderOperation {
        return BorderRenderOperation()
    }

    @inlinable @inline(__always)
    static func bindVertexBuffer(index: UInt, firstBinding: UInt = 0) -> RenderOperation {
        return BindVertexBufferRenderOperation(index: index, firstBinding: firstBinding)
    }

    @inlinable @inline(__always)
    static func pushCommandBuffer() -> RenderOperation {
        return PushCommandBufferRenderOperation()
    }

    @inlinable @inline(__always)
    static func popCommandBuffer() -> RenderOperation {
        return PopCommandBufferRenderOperation()
    }

    @inlinable @inline(__always)
    static func wait(fence: Fence) -> RenderOperation {
        return WaitFenceRenderOperation(fence: fence)
    }

    @inlinable @inline(__always)
    static func reset(fence: Fence) -> RenderOperation {
        return ResetFenceRenderOperation(fence: fence)
    }

    @inlinable @inline(__always)
    static func submitCommandBuffer(waitSemaphores: [Volcano.Semaphore] = [], signalSemaphores: [Volcano.Semaphore] = [], waitStages: [VkPipelineStageFlags] = [], fence: Fence) -> RenderOperation {
        return SubmitCommandBufferRenderOperation(waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, waitStages: waitStages, fence: fence)
    }

    @inlinable @inline(__always)
    static func pushRenderTarget(renderTarget: RenderTarget) -> RenderOperation {
        return PushRenderTargetRenderOperation(renderTarget: renderTarget)
    }

    @inlinable @inline(__always)
    static func popRenderTarget(rebind: Bool) -> RenderOperation {
        return PopRenderTargetRenderOperation(rebind: rebind)
    }

    @inlinable @inline(__always)
    static func contents(texture: Texture, layerIndex: UInt) -> RenderOperation {
        return ContentsRenderOperation(texture: texture, layerIndex: layerIndex)
    }

    @inlinable @inline(__always)
    static func updateModelViewProjection(modelViewProjection: RenderContext.ModelViewProjection) -> RenderOperation {
        return UpdateModelViewProjectionRenderOperation(modelViewProjection: modelViewProjection)
    }
}

internal class BindVertexBufferRenderOperation: RenderOperation {
    fileprivate let index: CUnsignedInt
    fileprivate lazy var offset = VkDeviceSize(index * UInt32(MemoryLayout<LayerRenderDescriptor>.stride))
    fileprivate let firstBinding: CUnsignedInt

    init(index: UInt, firstBinding: UInt) {
        self.index = CUnsignedInt(index)
        self.firstBinding = CUnsignedInt(firstBinding)

        super.init()
    }

    override func perform(in context: RenderContext) throws {
        let vertexBuffer = try context.vertexBuffer
        try context.commandBuffer.bind(vertexBuffer: vertexBuffer, offset: offset, firstBinding: firstBinding)
    }
}

internal class PushCommandBufferRenderOperation: RenderOperation {
    override func perform(in context: RenderContext) throws {
        let commandBuffer = try context.commandPool.createCommandBuffer()
        context.commandBuffersStack.push(commandBuffer)
        try commandBuffer.begin()
    }
}

internal class PopCommandBufferRenderOperation: RenderOperation {
    override func perform(in context: RenderContext) throws {
        context.commandBuffersStack.pop()
    }
}

internal class WaitFenceRenderOperation: RenderOperation {
    internal let fence: Fence
    
    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: RenderContext) throws {
        try fence.wait()
    }
}

internal class ResetFenceRenderOperation: RenderOperation {
    internal let fence: Fence

    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: RenderContext) throws {
        try fence.reset()
    }
}

internal class SubmitCommandBufferRenderOperation: RenderOperation {
    fileprivate let waitSemaphores: [Volcano.Semaphore]
    fileprivate let signalSemaphores: [Volcano.Semaphore]
    fileprivate let waitStages: [VkPipelineStageFlags]
    fileprivate let fence: Fence

    init(waitSemaphores: [Volcano.Semaphore], signalSemaphores: [Volcano.Semaphore], waitStages: [VkPipelineStageFlags], fence: Fence) {
        self.waitSemaphores = waitSemaphores
        self.signalSemaphores = signalSemaphores
        self.waitStages = waitStages
        self.fence = fence

        super.init()
    }

    override func perform(in context: RenderContext) throws {
        let commandBuffer = context.commandBuffer

        try commandBuffer.end()

        try context.graphicsQueue.submit(commandBuffers: [commandBuffer], waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, waitStages: waitStages, fence: fence)
    }
}

internal class BackgroundRenderOperation: RenderOperation {
    override func perform(in context: RenderContext) throws {
        let commandBuffer = context.commandBuffer
        let backgroundPipeline = context.pipelines.background
        try commandBuffer.bind(pipeline: backgroundPipeline)

        try commandBuffer.bind(descriptorSets: [context.modelViewProjectionDescriptorSet], for: backgroundPipeline)

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class BorderRenderOperation: RenderOperation {
    override func perform(in context: RenderContext) throws {
        let commandBuffer = context.commandBuffer
        let borderPipeline = context.pipelines.border
        try commandBuffer.bind(pipeline: borderPipeline)

        try commandBuffer.bind(descriptorSets: [context.modelViewProjectionDescriptorSet], for: borderPipeline)

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class PushRenderTargetRenderOperation: RenderOperation {
    internal let renderTarget: RenderTarget

    init(renderTarget: RenderTarget) {
        self.renderTarget = renderTarget

        super.init()
    }

    override func perform(in context: RenderContext) throws {
        context.renderTargetsStack.push(renderTarget)
        
        let commandBuffer = context.commandBuffer
        var clearValues: [VkClearValue] = []
        if let clearColor = renderTarget.clearColor {
            clearValues.append(clearColor)
        }
        try commandBuffer.begin(renderPass: renderTarget.renderPass, framebuffer: renderTarget.framebuffer, renderArea: renderTarget.renderArea, clearValues: clearValues)

        let viewports = [renderTarget.viewport]
        let scissors = [renderTarget.renderArea]
        
        try commandBuffer.setViewports(viewports)
        try commandBuffer.setScissors(scissors)
    }
}

internal class PopRenderTargetRenderOperation: RenderOperation {
    internal let rebind: Bool

    init(rebind: Bool = true) {
        self.rebind = rebind

        super.init()
    }

    override func perform(in context: RenderContext) throws {
        let commandBuffer = context.commandBuffer

        try commandBuffer.endRenderPass()

        context.renderTargetsStack.pop()

        if rebind {
            let renderTarget = context.renderTarget

            try commandBuffer.begin(renderPass: renderTarget.renderPass, framebuffer: renderTarget.framebuffer, renderArea: renderTarget.renderArea)
        }
    }
}

internal class ContentsRenderOperation: RenderOperation {
    internal let texture: Texture
    internal let layerIndex: UInt

    init(texture: Texture, layerIndex: UInt) {
        self.texture = texture
        self.layerIndex = layerIndex
    }

    override func perform(in context: RenderContext) throws {
        let commandBuffer = context.commandBuffer
        let contentsPipeline = context.pipelines.contents
        try commandBuffer.bind(pipeline: contentsPipeline)

        let contentsDescriptorSet = try context.contentsDescriptorSet(for: texture, layerIndex: layerIndex)

        try commandBuffer.bind(descriptorSets: [context.modelViewProjectionDescriptorSet, contentsDescriptorSet], for: contentsPipeline)

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class UpdateModelViewProjectionRenderOperation: RenderOperation {
    internal let modelViewProjection: RenderContext.ModelViewProjection

    init(modelViewProjection: RenderContext.ModelViewProjection) {
        self.modelViewProjection = modelViewProjection
    }

    override func perform(in context: RenderContext) throws {
        try withUnsafePointer(to: modelViewProjection) {
            try context.modelViewProjectionBuffer.memoryChunk.write(data: UnsafeBufferPointer(start: $0, count: 1))
        }
    }
}
