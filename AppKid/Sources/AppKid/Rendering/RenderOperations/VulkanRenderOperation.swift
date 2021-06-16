//
//  VulkanRenderOperation.swift
//  AppKid
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

internal class VulkanRenderContext {
    let renderStack: VulkanRenderStack
    let renderTargetsStack = SimpleStack<VulkanRenderTarget>()
    let commandBuffersStack = SimpleStack<CommandBuffer>()
    let viewportsStack = SimpleStack<VkViewport>()
    let queues: Queues
    let pipelines: Pipelines
    let imageFormat: VkFormat

    @inlinable @inline(__always)
    var graphicsQueue: Queue { queues.graphics }

    @inlinable @inline(__always)
    var transferQueue: Queue { queues.transfer }
    
    let commandPool: CommandPool
    let transferCommandPool: CommandPool

    var descriptors: [LayerRenderDescriptor] = []
    var operations: [VulkanRenderOperation] = []

    @inlinable @inline(__always)
    var renderTarget: VulkanRenderTarget { renderTargetsStack.root }

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

    init(renderStack: VulkanRenderStack, queues: Queues, pipelines: Pipelines, imageFormat: VkFormat = .rgba8UNorm) throws {
        let device = renderStack.device

        self.renderStack = renderStack
        self.queues = queues
        self.pipelines = pipelines
        self.commandPool = try CommandPool(device: device, queue: queues.graphics)
        self.transferCommandPool = try CommandPool(device: device, queue: queues.transfer, flags: .transient)
        self.imageFormat = imageFormat
    }

    func clear() throws {
        descriptors.removeAll()
        operations.removeAll()
        _vertexBuffer = nil
    }

    func performOperations() throws {
        try operations.forEach { try $0.perform(in: self) }
    }

    func add(_ operation: VulkanRenderOperation) {
        operations.append(operation)
    }

    func add(_ operations: [VulkanRenderOperation]) {
        self.operations.append(contentsOf: operations)
    }
}

extension VulkanRenderContext {
    struct Pipelines {
        let background: GraphicsPipeline
        let border: GraphicsPipeline
    }

    struct Queues {
        let graphics: Queue
        let transfer: Queue
    }
}

internal class VulkanRenderOperation {
    func perform(in context: VulkanRenderContext) throws {}

    @inlinable @inline(__always)
    static func background(descriptorSets: [VkDescriptorSet]? = nil) -> VulkanRenderOperation {
        return BackgroundRenderOperation(descriptorSets: descriptorSets)
    }

    @inlinable @inline(__always)
    static func border(descriptorSets: [VkDescriptorSet]? = nil) -> VulkanRenderOperation {
        return BorderRenderOperation(descriptorSets: descriptorSets)
    }

    @inlinable @inline(__always)
    static func bindVertexBuffer(index: CUnsignedInt, firstBinding: CUnsignedInt = 0) -> VulkanRenderOperation {
        return BindVertexBufferRenderOperation(index: index, firstBinding: firstBinding)
    }

    @inlinable @inline(__always)
    static func pushCommandBuffer() -> VulkanRenderOperation {
        return PushCommandBufferRenderOperation()
    }

    @inlinable @inline(__always)
    static func popCommandBuffer() -> VulkanRenderOperation {
        return PopCommandBufferRenderOperation()
    }

    @inlinable @inline(__always)
    static func wait(fence: Fence) -> VulkanRenderOperation {
        return WaitFenceRenderOperation(fence: fence)
    }

    @inlinable @inline(__always)
    static func reset(fence: Fence) -> VulkanRenderOperation {
        return ResetFenceRenderOperation(fence: fence)
    }

    @inlinable @inline(__always)
    static func submitCommandBuffer(waitSemaphores: [Volcano.Semaphore], signalSemaphores: [Volcano.Semaphore], waitStages: [VkPipelineStageFlags], fence: Fence) -> VulkanRenderOperation {
        return SubmitCommandBufferRenderOperation(waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, waitStages: waitStages, fence: fence)
    }

    @inlinable @inline(__always)
    static func pushRenderTarget(renderTarget: VulkanRenderTarget) -> VulkanRenderOperation {
        return PushRenderTargetRenderOperation(renderTarget: renderTarget)
    }

    @inlinable @inline(__always)
    static func popRenderTarget(rebind: Bool) -> VulkanRenderOperation {
        return PopRenderTargetRenderOperation(rebind: rebind)
    }
}

internal class BindVertexBufferRenderOperation: VulkanRenderOperation {
    fileprivate let index: UInt32
    fileprivate lazy var offset = VkDeviceSize(index * UInt32(MemoryLayout<LayerRenderDescriptor>.stride))
    fileprivate let firstBinding: CUnsignedInt

    init(index: UInt32, firstBinding: CUnsignedInt) {
        self.index = index
        self.firstBinding = firstBinding

        super.init()
    }

    override func perform(in context: VulkanRenderContext) throws {
        let vertexBuffer = try context.vertexBuffer
        try context.commandBuffer.bind(vertexBuffer: vertexBuffer, offset: offset, firstBinding: firstBinding)
    }
}

internal class PushCommandBufferRenderOperation: VulkanRenderOperation {
    override func perform(in context: VulkanRenderContext) throws {
        let commandBuffer = try context.commandPool.createCommandBuffer()
        context.commandBuffersStack.push(commandBuffer)
        try commandBuffer.begin()
    }
}

internal class PopCommandBufferRenderOperation: VulkanRenderOperation {
    override func perform(in context: VulkanRenderContext) throws {
        context.commandBuffersStack.pop()
    }
}

internal class WaitFenceRenderOperation: VulkanRenderOperation {
    internal let fence: Fence
    
    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: VulkanRenderContext) throws {
        try fence.wait()
    }
}

internal class ResetFenceRenderOperation: VulkanRenderOperation {
    internal let fence: Fence

    init(fence: Fence) {
        self.fence = fence

        super.init()
    }

    override func perform(in context: VulkanRenderContext) throws {
        try fence.reset()
    }
}

internal class SubmitCommandBufferRenderOperation: VulkanRenderOperation {
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

    override func perform(in context: VulkanRenderContext) throws {
        let commandBuffer = context.commandBuffer
        try commandBuffer.end()
        try context.graphicsQueue.submit(commandBuffers: [commandBuffer], waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, waitStages: waitStages, fence: fence)
    }
}

internal class BackgroundRenderOperation: VulkanRenderOperation {
    internal let descriptorSets: [VkDescriptorSet]?

    init(descriptorSets: [VkDescriptorSet]?) {
        self.descriptorSets = descriptorSets
    }

    override func perform(in context: VulkanRenderContext) throws {
        let commandBuffer = context.commandBuffer
        let backgroundPipeline = context.pipelines.background
        try commandBuffer.bind(pipeline: backgroundPipeline)

        if let descriptorSets = self.descriptorSets {
            try commandBuffer.bind(descriptorSets: descriptorSets, for: backgroundPipeline)
        }

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class BorderRenderOperation: VulkanRenderOperation {
    internal let descriptorSets: [VkDescriptorSet]?

    init(descriptorSets: [VkDescriptorSet]?) {
        self.descriptorSets = descriptorSets
    }

    override func perform(in context: VulkanRenderContext) throws {
        let commandBuffer = context.commandBuffer
        let borderPipeline = context.pipelines.border
        try commandBuffer.bind(pipeline: borderPipeline)

        if let descriptorSets = self.descriptorSets {
            try commandBuffer.bind(descriptorSets: descriptorSets, for: borderPipeline)
        }

        try commandBuffer.draw(vertexCount: 6)
    }
}

internal class PushRenderTargetRenderOperation: VulkanRenderOperation {
    internal let renderTarget: VulkanRenderTarget

    init(renderTarget: VulkanRenderTarget) {
        self.renderTarget = renderTarget

        super.init()
    }

    override func perform(in context: VulkanRenderContext) throws {
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

internal class PopRenderTargetRenderOperation: VulkanRenderOperation {
    internal let rebind: Bool

    init(rebind: Bool = true) {
        self.rebind = rebind

        super.init()
    }

    override func perform(in context: VulkanRenderContext) throws {
        let commandBuffer = context.commandBuffer

        try commandBuffer.endRenderPass()

        context.renderTargetsStack.pop()

        if rebind {
            let renderTarget = context.renderTarget

            try commandBuffer.begin(renderPass: renderTarget.renderPass, framebuffer: renderTarget.framebuffer, renderArea: renderTarget.renderArea)
        }
    }
}
