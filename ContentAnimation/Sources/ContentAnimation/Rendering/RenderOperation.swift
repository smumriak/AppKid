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
    var operations: [RenderOperation] = []

    internal var vertexBufferCopyCount: UInt64 = 0
    internal var vertexBufferCopySemaphore: TimelineSemaphore

    public private(set) var disposalBag = DisposalBag()

    @usableFromInline internal var sceneRenderTarget: RenderTarget! {
        didSet {
            disposalBag.append(sceneRenderTarget!)
        }
    }

    @usableFromInline internal var mainCommandBuffer: CommandBuffer! {
        didSet {
            disposalBag.append(mainCommandBuffer!)
        }
    }

    @inlinable @inline(__always)
    internal var renderTarget: RenderTarget { renderTargetsStack.first ?? sceneRenderTarget }

    @inlinable @inline(__always)
    internal var commandBuffer: CommandBuffer { commandBuffersStack.first ?? mainCommandBuffer }

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

        let vertexBufferDescriptor = BufferDescriptor()
        vertexBufferDescriptor.size = bufferSize
        vertexBufferDescriptor.usage = [.vertexBuffer, .transferDestination]
        vertexBufferDescriptor.requiredMemoryProperties = .deviceLocal
        vertexBufferDescriptor.setAccessQueues([graphicsQueue, transferQueue])

        let vertexBuffer = try renderStack.device.memoryAllocator.create(with: vertexBufferDescriptor).result

        disposalBag.append(vertexBuffer)

        return vertexBuffer
    }

    internal func populateVertexBuffer() throws {
        let vertexBuffer = try self.vertexBuffer
        let bufferSize = vertexBuffer.size

        let stagingBufferDescriptor = BufferDescriptor(stagingWithSize: bufferSize, accessQueues: [graphicsQueue, transferQueue])

        let stagingBuffer = try renderStack.device.memoryAllocator.create(with: stagingBufferDescriptor).result

        try descriptors.withUnsafeBufferPointer { renderDescriptors in
            try stagingBuffer.memoryChunk.withMappedData { data, size in
                data.copyMemory(from: UnsafeRawPointer(renderDescriptors.baseAddress!), byteCount: Int(stagingBuffer.size))
            }
        }

        try transferQueue.oneShot(in: transferCommandPool, wait: true, semaphores: [vertexBufferCopySemaphore]) {
            try $0.copyBuffer(from: stagingBuffer, to: vertexBuffer)
        }
        vertexBufferCopyCount += 1
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
            var writeInfo = VkWriteDescriptorSet.new()
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

        let modelViewProjectionBufferDescriptor = BufferDescriptor()
        modelViewProjectionBufferDescriptor.size = VkDeviceSize(MemoryLayout<ModelViewProjection>.size)
        modelViewProjectionBufferDescriptor.usage = [.uniformBuffer]
        modelViewProjectionBufferDescriptor.requiredMemoryProperties = [.hostVisible, .hostCoherent]
        modelViewProjectionBufferDescriptor.setAccessQueues([renderStack.queues.graphics, renderStack.queues.transfer])

        modelViewProjectionBuffer = try renderStack.device.memoryAllocator.create(with: modelViewProjectionBufferDescriptor).result

        let sizes = [VkDescriptorPoolSize(type: .uniformBuffer, descriptorCount: 1)]
        modelViewProjectionDescriptorPool = try DescriptorPool(device: device, sizes: sizes, maxSets: 1)
        let modelViewProjectionDescriptorSet = try modelViewProjectionDescriptorPool.allocate(with: descriptorSetsLayouts.modelViewProjection)
        self.modelViewProjectionDescriptorSet = modelViewProjectionDescriptorSet

        var bufferInfo = VkDescriptorBufferInfo()
        bufferInfo.buffer = modelViewProjectionBuffer.handle
        bufferInfo.offset = 0
        bufferInfo.range = VkDeviceSize(MemoryLayout<RenderContext1.ModelViewProjection>.stride)

        try withUnsafePointer(to: &bufferInfo) { bufferInfo in
            var writeInfo = VkWriteDescriptorSet.new()
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

        vertexBufferCopySemaphore = try TimelineSemaphore(device: device)
    }

    func clear() throws {
        disposalBag = DisposalBag()
        descriptors.removeAll()
        operations.removeAll()
        vertexBufferCopyCount = 0
        vertexBufferCopySemaphore = try TimelineSemaphore(device: renderStack.device)
        // _vertexBuffer = nil
    }

    func performOperations() throws {
        try populateVertexBuffer()
        try operations.forEach { try $0.perform(in: self) }
    }

    func add(_ operation: RenderOperation) {
        operations.append(operation)
    }

    func add(_ operations: [RenderOperation]) {
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

internal class RenderOperation {
    func perform(in context: RenderContext1) throws {}

    @inlinable @inline(__always)
    static func begineScene() -> RenderOperation {
        return BegineSceneRenderOperation()
    }
    
    @inlinable @inline(__always)
    static func endScene() -> RenderOperation {
        return EndSceneRenderOperation()
    }

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
    static func pushCommandBuffer(_ commandBuffer: CommandBuffer? = nil) -> RenderOperation {
        return PushCommandBufferRenderOperation(commandBuffer: commandBuffer)
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
    static func pushRenderTarget(_ renderTarget: RenderTarget) -> RenderOperation {
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
    static func updateModelViewProjection(modelViewProjection: RenderContext1.ModelViewProjection) -> RenderOperation {
        return UpdateModelViewProjectionRenderOperation(modelViewProjection: modelViewProjection)
    }
}

internal class BegineSceneRenderOperation: RenderOperation {
    override func perform(in context: RenderContext1) throws {
        guard let commandBuffer = context.mainCommandBuffer else {
            fatalError("No main command buffer attached")
        }

        guard let renderTarget = context.sceneRenderTarget else {
            fatalError("No scene render target attached")
        }
        
        context.commandBuffersStack.prepend(commandBuffer)
        try commandBuffer.begin()

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

internal class EndSceneRenderOperation: RenderOperation {
    override func perform(in context: RenderContext1) throws {
        let commandBuffer = context.commandBuffer

        try commandBuffer.endRenderPass()

        context.renderTargetsStack.removeFirst()

        try commandBuffer.end()

        context.commandBuffersStack.removeFirst()
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

    override func perform(in context: RenderContext1) throws {
        let vertexBuffer = try context.vertexBuffer
        try context.commandBuffer.bind(vertexBuffer: vertexBuffer, offset: offset, firstBinding: firstBinding)
    }
}

internal class PushCommandBufferRenderOperation: RenderOperation {
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

internal class PopCommandBufferRenderOperation: RenderOperation {
    override func perform(in context: RenderContext1) throws {
        try context.commandBuffer.end()

        context.commandBuffersStack.removeFirst()
    }
}

internal class WaitFenceRenderOperation: RenderOperation {
    internal let fence: Fence
    
    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: RenderContext1) throws {
        try fence.wait()
    }
}

internal class ResetFenceRenderOperation: RenderOperation {
    internal let fence: Fence

    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: RenderContext1) throws {
        try fence.reset()
    }
}

internal class BackgroundRenderOperation: RenderOperation {
    override func perform(in context: RenderContext1) throws {
        let commandBuffer = context.commandBuffer
        let backgroundPipeline = context.pipelines.background
        try commandBuffer.bind(pipeline: backgroundPipeline)

        try commandBuffer.bind(descriptorSets: [context.modelViewProjectionDescriptorSet], for: backgroundPipeline)

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class BorderRenderOperation: RenderOperation {
    override func perform(in context: RenderContext1) throws {
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

internal class PopRenderTargetRenderOperation: RenderOperation {
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

internal class ContentsRenderOperation: RenderOperation {
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

internal class UpdateModelViewProjectionRenderOperation: RenderOperation {
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
