//
//  RenderOperation.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 13.04.2021.
//

import Foundation
import CoreFoundation
import Collections
@_spi(AppKid) import CairoGraphics
@_spi(AppKid) import Volcano
import CVulkan
import TinyFoundation
import LayerRenderingData

@_spi(AppKid) public class RenderContext1 {
    typealias ModelViewProjection = (model: mat4s, view: mat4s, projection: mat4s)

    @usableFromInline let renderStack: VolcanoRenderStack
    @usableFromInline var renderTargetsStack = Deque<RenderTarget>()
    @usableFromInline var commandBuffersStack = Deque<CommandBuffer>()
    let pipelines: Pipelines
    let descriptorSetsLayouts: DescriptorSetsLayouts
    let imageFormat: VkFormat

    @inlinable @inline(__always)
    internal var graphicsQueue: Queue { renderStack.queues.graphics }

    @inlinable @inline(__always)
    internal var transferQueue: Queue { renderStack.queues.transfer }
    
    let commandPool: CommandPool
    let transferCommandPool: CommandPool

    var descriptors: [LayerRenderDescriptor] = []
    var operations: [RenderOperation1] = []

    @inlinable @inline(__always)
    internal var renderTarget: RenderTarget { renderTargetsStack.first! }

    @inlinable @inline(__always)
    internal var commandBuffer: CommandBuffer { commandBuffersStack.first! }

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

    let modelViewProjection: ModelViewProjection = (.identity, .identity, .identity)
    func updateModelViewProjection(_ modelViewProjection: ModelViewProjection) throws {
        guard modelViewProjection != self.modelViewProjection else {
            return
        }
        
        try withUnsafePointer(to: modelViewProjection) {
            try modelViewProjectionBuffer.memoryChunk.write(data: UnsafeBufferPointer(start: $0, count: 1))
        }
    }

    let contentsDescriptorsSetCache: DescriptorsSetCache

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
        let textureIdentifier = ObjectIdentifier(texture)

        if let result = contentsDescriptorsSetCache.existingDescriptorSet(for: textureIdentifier) {
            return result
        }

        let descriptorSet = try contentsDescriptorsSetCache.createDescriptorSet(for: textureIdentifier)
        texture.addDeinitHook { [weak contentsDescriptorsSetCache] in
            if let contentsDescriptorsSetCache = contentsDescriptorsSetCache {
                contentsDescriptorsSetCache.releaseDescriptorSet(for: textureIdentifier)
            }
        }

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
        self.commandPool = try renderStack.queues.graphics.createCommandPool()
        self.transferCommandPool = try renderStack.queues.transfer.createCommandPool(flags: .transient)
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
        bufferInfo.range = VkDeviceSize(MemoryLayout<RenderContext1.ModelViewProjection>.stride)

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

        contentsDescriptorsSetCache = try DescriptorsSetCache(device: device, layout: descriptorSetsLayouts.contentsSampler, sizes: [(type: .combinedImageSampler, count: 500)], maxSets: 500)
    }

    func clear() throws {
        descriptors.removeAll()
        operations.removeAll()
        _vertexBuffer = nil
    }

    func performOperations() throws {
        try operations.forEach { try $0.perform(in: self) }
    }

    func add(_ operation: RenderOperation1) {
        operations.append(operation)
    }

    func add(_ operations: [RenderOperation1]) {
        self.operations.append(contentsOf: operations)
    }
}

extension RenderContext1 {
    struct Pipelines {
        let background: GraphicsPipeline
        let border: GraphicsPipeline
        let contents: GraphicsPipeline
    }
}

internal class RenderOperation1 {
    func perform(in context: RenderContext1) throws {}

    @inlinable @inline(__always)
    static func background() -> RenderOperation1 {
        return BackgroundRenderOperation1()
    }

    @inlinable @inline(__always)
    static func border() -> RenderOperation1 {
        return BorderRenderOperation1()
    }

    @inlinable @inline(__always)
    static func bindVertexBuffer(index: UInt, firstBinding: UInt = 0) -> RenderOperation1 {
        return BindVertexBufferRenderOperation1(index: index, firstBinding: firstBinding)
    }

    @inlinable @inline(__always)
    static func pushCommandBuffer(_ commandBuffer: CommandBuffer? = nil) -> RenderOperation1 {
        return PushCommandBufferRenderOperation1(commandBuffer: commandBuffer)
    }

    @inlinable @inline(__always)
    static func popCommandBuffer() -> RenderOperation1 {
        return PopCommandBufferRenderOperation1()
    }

    @inlinable @inline(__always)
    static func wait(fence: Fence) -> RenderOperation1 {
        return WaitFenceRenderOperation1(fence: fence)
    }

    @inlinable @inline(__always)
    static func reset(fence: Fence) -> RenderOperation1 {
        return ResetFenceRenderOperation1(fence: fence)
    }

    @inlinable @inline(__always)
    static func pushRenderTarget(_ renderTarget: RenderTarget) -> RenderOperation1 {
        return PushRenderTargetRenderOperation1(renderTarget: renderTarget)
    }

    @inlinable @inline(__always)
    static func popRenderTarget(rebind: Bool) -> RenderOperation1 {
        return PopRenderTargetRenderOperation1(rebind: rebind)
    }

    @inlinable @inline(__always)
    static func contents(texture: Texture, layerIndex: UInt) -> RenderOperation1 {
        return ContentsRenderOperation1(texture: texture, layerIndex: layerIndex)
    }

    @inlinable @inline(__always)
    static func updateModelViewProjection(modelViewProjection: RenderContext1.ModelViewProjection) -> RenderOperation1 {
        return UpdateModelViewProjectionRenderOperation1(modelViewProjection: modelViewProjection)
    }
}

internal class BindVertexBufferRenderOperation1: RenderOperation1 {
    fileprivate let index: CUnsignedInt
    fileprivate lazy var offset = VkDeviceSize(index * UInt32(MemoryLayout<LayerRenderDescriptor>.stride))
    fileprivate let firstBinding: CUnsignedInt

    init(index: UInt, firstBinding: UInt) {
        self.index = CUnsignedInt(index)
        self.firstBinding = CUnsignedInt(firstBinding)

        super.init()
    }

    override func perform(in context: RenderContext1) throws {
        let vertexBuffer = try context.vertexBuffer
        try context.commandBuffer.bind(vertexBuffer: vertexBuffer, offset: offset, firstBinding: firstBinding)
    }
}

internal class PushCommandBufferRenderOperation1: RenderOperation1 {
    let commandBuffer: CommandBuffer?
    
    init(commandBuffer: CommandBuffer? = nil) {
        self.commandBuffer = commandBuffer
    }

    override func perform(in context: RenderContext1) throws {
        let commandBuffer = try commandBuffer ?? context.commandPool.createCommandBuffer()
        context.commandBuffersStack.prepend(commandBuffer)
        try commandBuffer.begin()
    }
}

internal class PopCommandBufferRenderOperation1: RenderOperation1 {
    override func perform(in context: RenderContext1) throws {
        try context.commandBuffer.end()

        context.commandBuffersStack.removeFirst()
    }
}

internal class WaitFenceRenderOperation1: RenderOperation1 {
    internal let fence: Fence
    
    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: RenderContext1) throws {
        try fence.wait()
    }
}

internal class ResetFenceRenderOperation1: RenderOperation1 {
    internal let fence: Fence

    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: RenderContext1) throws {
        try fence.reset()
    }
}

internal class BackgroundRenderOperation1: RenderOperation1 {
    override func perform(in context: RenderContext1) throws {
        let commandBuffer = context.commandBuffer
        let backgroundPipeline = context.pipelines.background
        try commandBuffer.bind(pipeline: backgroundPipeline)

        try commandBuffer.bind(descriptorSets: [context.modelViewProjectionDescriptorSet], for: backgroundPipeline)

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class BorderRenderOperation1: RenderOperation1 {
    override func perform(in context: RenderContext1) throws {
        let commandBuffer = context.commandBuffer
        let borderPipeline = context.pipelines.border
        try commandBuffer.bind(pipeline: borderPipeline)

        try commandBuffer.bind(descriptorSets: [context.modelViewProjectionDescriptorSet], for: borderPipeline)

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class PushRenderTargetRenderOperation1: RenderOperation1 {
    internal let renderTarget: RenderTarget

    init(renderTarget: RenderTarget) {
        self.renderTarget = renderTarget

        super.init()
    }

    override func perform(in context: RenderContext1) throws {
        let commandBuffer = context.commandBuffer

        if context.renderTargetsStack.isEmpty == false {
            try commandBuffer.endRenderPass()
        }

        context.renderTargetsStack.prepend(renderTarget)
        
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

internal class PopRenderTargetRenderOperation1: RenderOperation1 {
    internal let rebind: Bool

    init(rebind: Bool = true) {
        self.rebind = rebind

        super.init()
    }

    override func perform(in context: RenderContext1) throws {
        let commandBuffer = context.commandBuffer

        try commandBuffer.endRenderPass()

        context.renderTargetsStack.removeFirst()

        if rebind {
            let renderTarget = context.renderTarget

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
}

internal class ContentsRenderOperation1: RenderOperation1 {
    internal let texture: Texture
    internal let layerIndex: UInt

    init(texture: Texture, layerIndex: UInt) {
        self.texture = texture
        self.layerIndex = layerIndex
    }

    override func perform(in context: RenderContext1) throws {
        let commandBuffer = context.commandBuffer
        let contentsPipeline = context.pipelines.contents
        try commandBuffer.bind(pipeline: contentsPipeline)

        let contentsDescriptorSet = try context.contentsDescriptorSet(for: texture, layerIndex: layerIndex)

        try commandBuffer.bind(descriptorSets: [context.modelViewProjectionDescriptorSet, contentsDescriptorSet], for: contentsPipeline)

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class UpdateModelViewProjectionRenderOperation1: RenderOperation1 {
    internal let modelViewProjection: RenderContext1.ModelViewProjection

    init(modelViewProjection: RenderContext1.ModelViewProjection) {
        self.modelViewProjection = modelViewProjection
    }

    override func perform(in context: RenderContext1) throws {
        try withUnsafePointer(to: modelViewProjection) {
            try context.modelViewProjectionBuffer.memoryChunk.write(data: UnsafeBufferPointer(start: $0, count: 1))
        }
    }
}
