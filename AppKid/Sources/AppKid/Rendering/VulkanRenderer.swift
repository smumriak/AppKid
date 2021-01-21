//
//  VulkanRenderer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import Foundation
import CoreFoundation
import Volcano
import TinyFoundation
import CVulkan
import SimpleGLM
import ContentAnimation
import CairoGraphics
import CXlib
import SwiftXlib

public enum VulkanRendererError: Error {
    case noDiscreteGPU
    case noPresentationQueueFound
    case noGraphicsQueueFound
    case noTransferQueueFound
}

public final class VulkanRenderer {
    internal var window: AppKid.Window {
        didSet {
            try? render()
        }
    }

    internal var projectionMatrix: mat4s = .identity
    internal var viewMatrix: mat4s = .identity

    internal fileprivate(set) var renderStack: VulkanRenderStack

    internal var device: Device { renderStack.device }
    internal fileprivate(set) var surface: Surface

    internal fileprivate(set) var presentationQueue: Queue
    internal fileprivate(set) var graphicsQueue: Queue
    internal fileprivate(set) var transferQueue: Queue

    internal fileprivate(set) var commandPool: CommandPool
    internal fileprivate(set) var transferCommandPool: CommandPool

    internal fileprivate(set) var imageAvailableSemaphore: Semaphore
    internal fileprivate(set) var renderFinishedSemaphore: Semaphore
    internal fileprivate(set) var fence: Fence
    internal fileprivate(set) var renderPass: RenderPass

    fileprivate var vertices: [VertexDescriptor] = [
        VertexDescriptor(),
        VertexDescriptor(),
        VertexDescriptor(),
        VertexDescriptor(),
    ]

    fileprivate var indices: [CUnsignedInt] = [
        0, 1, 2, 0, 3, 1,
    ]

    var vertexShader: Shader
    var fragmentShader: Shader

    var oldSwapchain: Swapchain?
    var swapchain: Swapchain!
    var images: [Volcano.Image]!
    var imageViews: [ImageView]!

    var pipeline: GraphicsPipeline!
    var framebuffers: [Framebuffer] = []
    var commandBuffers: [CommandBuffer] = []
    var vertexBuffer: Buffer!
    var indexBuffer: Buffer!

    var uniformBuffers: [Buffer] = []
    var descriptorSetLayout: SmartPointer<VkDescriptorSetLayout_T>!
    var descriptorPool: SmartPointer<VkDescriptorPool_T>!
    var descriptorSets: [VkDescriptorSet] = []

    deinit {
        transformTimer.invalidate()

        try? clearSwapchain()
        oldSwapchain = nil
    }

    public init(window: AppKid.Window, renderStack: VulkanRenderStack) throws {
        self.window = window

        self.renderStack = renderStack
        let device = renderStack.device

        let surface = try renderStack.createSurface(for: window)
        self.surface = surface

        guard let presentationQueue = try device.allQueues.first(where: { try surface.supportsPresenting(on: $0) }) else {
            throw VulkanRendererError.noPresentationQueueFound
        }

        self.presentationQueue = presentationQueue

        guard let graphicsQueue = device.allQueues.first(where: { $0.type.contains(.graphics) }) else {
            throw VulkanRendererError.noGraphicsQueueFound
        }

        self.graphicsQueue = graphicsQueue

        guard let transferQueue = device.allQueues.first(where: { $0.type.contains(.transfer) }) else {
            throw VulkanRendererError.noTransferQueueFound
        }

        self.transferQueue = transferQueue

        commandPool = try CommandPool(device: device, queue: graphicsQueue)
        transferCommandPool = try CommandPool(device: device, queue: transferQueue, flags: .transient)

        imageAvailableSemaphore = try Semaphore(device: device)
        renderFinishedSemaphore = try Semaphore(device: device)
        fence = try Fence(device: device)

        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        vertexShader = try device.shader(named: "VertexShader", in: bundle)
        fragmentShader = try device.shader(named: "FragmentShader", in: bundle)

        var colorAttachmentDescription = VkAttachmentDescription()
        colorAttachmentDescription.format = surface.imageFormat
        colorAttachmentDescription.samples = .one
        colorAttachmentDescription.loadOp = .clear
        colorAttachmentDescription.storeOp = .store
        colorAttachmentDescription.stencilLoadOp = .clear
        colorAttachmentDescription.stencilStoreOp = .store
        colorAttachmentDescription.initialLayout = .undefined
        colorAttachmentDescription.finalLayout = .presentSource

        let colorAttachment = Attachment(description: colorAttachmentDescription, imageLayout: .colorAttachmentOptimal)
        let subpass1 = Subpass(bindPoint: .graphics, colorAttachments: [colorAttachment])
        let dependency1 = Subpass.Dependency(destination: subpass1, sourceStage: .colorAttachmentOutput, destinationStage: .colorAttachmentOutput, destinationAccess: .colorAttachmentWrite)

        renderPass = try RenderPass(device: device, subpasses: [subpass1], dependencies: [dependency1])

        descriptorSetLayout = try createDescriptorSetLayout()

        pipeline = try createGraphicsPipeline()

        vertexBuffer = try createVertexBuffer()
        indexBuffer = try createIndexBuffer()

        RunLoop.current.add(transformTimer, forMode: .common)
    }

    public func setupSwapchain() throws {
        try surface.refreshCapabilities()

        let windowSize = window.bounds.size
        let displayScale = window.nativeWindow.displayScale
        let desiredSize = VkExtent2D(width: UInt32(windowSize.width * displayScale), height: UInt32(windowSize.height * displayScale))
        let minSize = surface.capabilities.minImageExtent
        let maxSize = surface.capabilities.maxImageExtent

        let width = max(min(desiredSize.width, maxSize.width), minSize.width)
        let height = max(min(desiredSize.height, maxSize.height), minSize.height)
        let size = VkExtent2D(width: width, height: height)

        swapchain = try Swapchain(device: device, surface: surface, desiredPresentMode: .immediate, size: size, graphicsQueue: graphicsQueue, presentationQueue: presentationQueue, usage: .colorAttachment, compositeAlpha: .opaque, oldSwapchain: oldSwapchain)
        images = try swapchain.getImages()
        imageViews = try images.map { try ImageView(image: $0) }

        uniformBuffers = try createUniformBuffers()

        descriptorPool = try createDescriptorPool()
        descriptorSets = try createDescriptorSets()

        framebuffers = try createFramebuffers()
        commandBuffers = try createCommandBuffers()
        
        oldSwapchain = nil
    }

    fileprivate func updateTransforms() {
        // let bounds = window.bounds
    }

    public func clearSwapchain() throws {
        try device.waitForIdle()

        oldSwapchain = swapchain

        commandBuffers = []
        framebuffers = []
        uniformBuffers = []
        descriptorSets = []
        descriptorPool = nil
        imageViews = nil
        images = nil
        swapchain = nil
    }

    public func beginFrame() {
    }

    public func endFrame() {
    }

    public func render() throws {
        // trying to recreate swapchain only once per render request. if it fails for the second time - frame is skipped assuming there will be new render request following. maybe not the best thing to do because it's like a hidden logic. will re-evaluate
        var skipRecreation = false

        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier that x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        // let xlibFence = window.nativeWindow.syncFence
        // let display = window.nativeWindow.display
        // XSyncResetFence(display.handle, xlibFence)

        // defer {
        //     XSyncTriggerFence(display.handle, xlibFence)
        // }

        while true {
            do {
                object.projection = window.projectionMatrix
                try drawFrame()
                break
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDate {
                    if skipRecreation == true {
                        break
                    }

                    try clearSwapchain()

                    vertexBuffer = try createVertexBuffer()
                    indexBuffer = try createIndexBuffer()
                    
                    try setupSwapchain()

                    skipRecreation = true
                } else {
                    throw VulkanError.badResult(errorCode)
                }
            }
        }

        // previous rendering code that would not skip swapchain recreation. keeping here till re-evaluating the solution
//        var happyFrame = false
//        repeat {
//            do {
//                try drawFrame()
//                happyFrame = true
//            } catch VulkanError.badResult(let errorCode) {
//                if errorCode == .errorOutOfDate {
//                    try clearSwapchain()
//                    try setupSwapchain()
//                } else {
//                    throw VulkanError.badResult(errorCode)
//                }
//            }
//        } while happyFrame == false
    }

    public func updateRenderTargetSize() throws {
        do {
            try clearSwapchain()

            vertexBuffer = try createVertexBuffer()
            indexBuffer = try createIndexBuffer()

            try setupSwapchain()
        } catch {
            debugPrint("Failed to recreate swapchain with error: \(error)")
        }
    }

    public func drawFrame() throws {
        // let startTime = CFAbsoluteTimeGetCurrent()
        // debugPrint("Draw frame start: \(startTime)")
        try fence.reset()
        
        let imageIndex = try swapchain.getNextImageIndex(semaphore: imageAvailableSemaphore)

        try self.update(uniformBuffer: uniformBuffers[imageIndex])
        
        let commandBuffer = commandBuffers[imageIndex]

        let submitCommandBuffers: [CommandBuffer] = [commandBuffer]
        let waitSemaphores: [Semaphore] = [imageAvailableSemaphore]
        let signalSemaphores: [Semaphore] = [renderFinishedSemaphore]
        let waitStages: [VkPipelineStageFlags] = [VkPipelineStageFlagBits.colorAttachmentOutput.rawValue]

        try graphicsQueue.submit(commandBuffers: submitCommandBuffers, waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, waitStages: waitStages, fence: fence)
        try presentationQueue.present(swapchains: [swapchain], waitSemaphores: signalSemaphores, imageIndices: [CUnsignedInt(imageIndex)])

        try fence.wait()
        // let endTime = CFAbsoluteTimeGetCurrent()
        // debugPrint("Draw frame end: \(endTime)")
        // debugPrint("Frame draw took \((endTime - startTime) * 1000.0) ms")
    }

    func createGraphicsPipeline() throws -> GraphicsPipeline {
        let descriptor = GraphicsPipelineDescriptor()
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        descriptor.descriptorSetLayouts = [descriptorSetLayout]

        descriptor.viewportState = .dynamic(viewportsCount: 1, scissorsCount: 1)

        descriptor.vertexInputBindingDescriptions = [VertexDescriptor.inputBindingDescription()]
        descriptor.inputAttributeDescrioptions = VertexDescriptor.attributesDescriptions()

        descriptor.inputPrimitiveTopology = .triangleList
        descriptor.primitiveRestartEnabled = false

        descriptor.depthClampEnabled = false
        descriptor.discardEnabled = false
        descriptor.polygonMode = .fill
        descriptor.cullModeFlags = []
        descriptor.frontFace = .counterClockwise
        descriptor.depthBiasEnabled = false
        descriptor.depthBiasConstantFactor = 0.0
        descriptor.depthBiasClamp = 0.0
        descriptor.depthBiasSlopeFactor = 0.0
        descriptor.lineWidth = 1.0

        descriptor.sampleShadingEnabled = false
        descriptor.rasterizationSamples = .one
        descriptor.minSampleShading = 1.0
        descriptor.sampleMasks = []
        descriptor.alphaToCoverageEnabled = false
        descriptor.alphaToOneEnabled = false

        descriptor.logicOperationEnabled = false
        descriptor.logicOperation = .copy
        descriptor.colorBlendAttachments = [.rgbaBlend]
        descriptor.blendConstants = (0.0, 0.0, 0.0, 0.0)

        descriptor.dynamicStates = [
            .viewport,
            .scissor,
            .lineWidth,
        ]

        return try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: renderPass, subpassIndex: 0)
    }

    func createFramebuffers() throws -> [Framebuffer] {
        return try imageViews.map { imageView in
            return try Framebuffer(device: device, size: swapchain.size, renderPass: renderPass, attachments: [imageView])
        }
    }

    func createCommandBuffers() throws -> [CommandBuffer] {
        let renderArea = VkRect2D(offset: .zero, extent: swapchain.size)
        let clearColor = VkClearValue(color: .white)

        var viewport = VkViewport()
        viewport.x = 0.0
        viewport.y = 0.0
        viewport.width = Float(swapchain.size.width)
        viewport.height = Float(swapchain.size.height)
        viewport.minDepth = 0.0
        viewport.maxDepth = 1.0

        let viewports = [viewport]
        let scissors = [renderArea]

        let result: [CommandBuffer] = try zip(framebuffers, descriptorSets).map { framebuffer, descriptorSet in
            let commandBuffer = try CommandBuffer(commandPool: commandPool)

            try commandBuffer.record {
                try commandBuffer.begin(renderPass: renderPass, framebuffer: framebuffer, renderArea: renderArea, clearValues: [clearColor])
                try commandBuffer.bind(pipeline: pipeline)

                try commandBuffer.setViewports(viewports)
                try commandBuffer.setScissors(scissors)

                try commandBuffer.bind(vertexBuffers: [vertexBuffer])
                try commandBuffer.bind(indexBuffer: indexBuffer, type: .uint32)
                try commandBuffer.bind(descriptorSets: [descriptorSet], for: pipeline)

                try commandBuffer.drawIndexed(indexCount: CUnsignedInt(indices.count))

                try commandBuffer.endRenderPass()
            }

            return commandBuffer
        }

        return result
    }

    func createVertexBuffer() throws -> Buffer {
        if let view = window.subviews.first?.subviews.first?.subviews.first {
            vertices = view.vertices
        }

        let bufferSize = VkDeviceSize(MemoryLayout<VertexDescriptor>.stride * vertices.count)

        let stagingBuffer = try Buffer(device: device,
                                       size: bufferSize,
                                       usage: [.transferSource],
                                       sharingMode: .concurrent,
                                       memoryProperties: [.hostVisible, .hostCoherent],
                                       accessQueues: [graphicsQueue, transferQueue])

        try vertices.withUnsafeBufferPointer { vertices in
            try stagingBuffer.memoryChunk.withMappedData { data, size in
                data.copyMemory(from: UnsafeRawPointer(vertices.baseAddress!), byteCount: Int(stagingBuffer.size))
            }
        }

        let vertexBuffer = try Buffer(device: device,
                                      size: bufferSize,
                                      usage: [.vertexBuffer, .transferDestination],
                                      sharingMode: .concurrent,
                                      memoryProperties: .deviceLocal,
                                      accessQueues: [graphicsQueue, transferQueue])

        let commandBuffer = try CommandBuffer(commandPool: transferCommandPool, level: .primary)
        try commandBuffer.begin(flags: .oneTimeSubmit)
        try commandBuffer.copyBuffer(from: stagingBuffer, to: vertexBuffer)
        try commandBuffer.end()

        try transferQueue.submit(commandBuffers: [commandBuffer])
        try transferQueue.waitForIdle()

        return vertexBuffer
    }

    func createIndexBuffer() throws -> Buffer {
        let bufferSize = VkDeviceSize(MemoryLayout<CUnsignedInt>.stride * indices.count)

        let stagingBuffer = try Buffer(device: device,
                                       size: bufferSize,
                                       usage: [.transferSource],
                                       sharingMode: .concurrent,
                                       memoryProperties: [.hostVisible, .hostCoherent],
                                       accessQueues: [graphicsQueue, transferQueue])

        try indices.withUnsafeBufferPointer { indices in
            try stagingBuffer.memoryChunk.withMappedData { data, size in
                data.copyMemory(from: UnsafeRawPointer(indices.baseAddress!), byteCount: Int(stagingBuffer.size))
            }
        }

        let indexBuffer = try Buffer(device: device,
                                     size: bufferSize,
                                     usage: [.indexBuffer, .transferDestination],
                                     sharingMode: .concurrent,
                                     memoryProperties: .deviceLocal,
                                     accessQueues: [graphicsQueue, transferQueue])

        let commandBuffer = try CommandBuffer(commandPool: transferCommandPool, level: .primary)
        try commandBuffer.begin(flags: .oneTimeSubmit)
        try commandBuffer.copyBuffer(from: stagingBuffer, to: indexBuffer)
        try commandBuffer.end()

        try transferQueue.submit(commandBuffers: [commandBuffer])
        try transferQueue.waitForIdle()

        return indexBuffer
    }

    func createUniformBuffers() throws -> [Buffer] {
        let size = VkDeviceSize(MemoryLayout<UniformBufferObject>.size)
        return try (0..<images.count).map { _ in
            let result = try Buffer(device: device,
                                    size: size,
                                    usage: [.uniformBuffer],
                                    sharingMode: .concurrent,
                                    memoryProperties: [.hostVisible, .hostCoherent],
                                    accessQueues: [graphicsQueue, transferQueue])

            try update(uniformBuffer: result)
            return result
        }
    }

    func createDescriptorSetLayout() throws -> SmartPointer<VkDescriptorSetLayout_T> {
        var descriptorSetLayoutBinding = VkDescriptorSetLayoutBinding()
        descriptorSetLayoutBinding.binding = 0
        descriptorSetLayoutBinding.descriptorType = .uniformBuffer
        descriptorSetLayoutBinding.descriptorCount = 1
        descriptorSetLayoutBinding.stageFlags = VkShaderStageFlagBits.vertex.rawValue
        descriptorSetLayoutBinding.pImmutableSamplers = nil

        let descriptorSetLayoutBindings = [descriptorSetLayoutBinding]

        return try descriptorSetLayoutBindings.withUnsafeBufferPointer { descriptorSetLayoutBindings in
            var info = VkDescriptorSetLayoutCreateInfo()
            info.sType = .descriptorSetLayoutCreateInfo
            info.bindingCount = CUnsignedInt(descriptorSetLayoutBindings.count)
            info.pBindings = descriptorSetLayoutBindings.baseAddress!

            return try device.create(with: &info)
        }
    }

    func createDescriptorPool() throws -> SmartPointer<VkDescriptorPool_T> {
        var poolSize = VkDescriptorPoolSize()
        poolSize.type = .uniformBuffer
        poolSize.descriptorCount = CUnsignedInt(images.count)

        let sizes = [poolSize]

        return try sizes.withUnsafeBufferPointer { sizes in
            var info = VkDescriptorPoolCreateInfo()
            info.sType = .descriptorPoolCreateInfo
            info.poolSizeCount = CUnsignedInt(sizes.count)
            info.pPoolSizes = sizes.baseAddress!
            info.maxSets = CUnsignedInt(images.count)

            return try device.create(with: &info)
        }
    }

    func createDescriptorSets() throws -> [VkDescriptorSet] {
        let count = images.count
        let layouts: [VkDescriptorSetLayout?] = Array<SmartPointer<VkDescriptorSetLayout_T>>(repeating: descriptorSetLayout, count: count).map { $0.pointer }

        let descriptorSets: [VkDescriptorSet] = try layouts.withUnsafeBufferPointer { layouts in
            var info = VkDescriptorSetAllocateInfo()
            info.sType = .descriptorSetAllocateInfo
            info.descriptorPool = descriptorPool.pointer
            info.descriptorSetCount = CUnsignedInt(count)
            info.pSetLayouts = layouts.baseAddress!

            var result = Array<VkDescriptorSet?>(repeating: nil, count: count)

            try vulkanInvoke {
                vkAllocateDescriptorSets(device.handle, &info, &result)
            }

            return result.compactMap { $0 }
        }

        try descriptorSets.enumerated().forEach { offset, descriptorSet in
            var info = VkDescriptorBufferInfo()
            info.buffer = uniformBuffers[offset].handle
            info.offset = 0
            info.range = VkDeviceSize(MemoryLayout<UniformBufferObject>.stride)

            try withUnsafePointer(to: &info) { info in
                var descriptorWrite = VkWriteDescriptorSet()
                descriptorWrite.sType = .writeDescriptorSet
                descriptorWrite.dstSet = descriptorSet
                descriptorWrite.dstBinding = 0
                descriptorWrite.dstArrayElement = 0
                descriptorWrite.descriptorCount = 1
                descriptorWrite.descriptorType = .uniformBuffer
                descriptorWrite.pBufferInfo = info
                descriptorWrite.pImageInfo = nil
                descriptorWrite.pTexelBufferView = nil

                try withUnsafePointer(to: &descriptorWrite) { descriptorWrite in
                    try vulkanInvoke {
                        vkUpdateDescriptorSets(device.handle, 1, descriptorWrite, 0, nil)
                    }
                }
            }
        }

        return descriptorSets
    }

    lazy var object: UniformBufferObject = {
        let bounds = self.window.bounds
        
        let model = mat4s.identity
        let view = mat4s.identity
        // let view = mat4s(lootAt: vec3s(2.0, 2.0, 2.0), center: vec3s(0.0, 0.0, 0.0), up: vec3s(0.0, 0.0, 1.0))
        // let view = mat4s(scaleVector: vec3s(x: 100.0, y: 100.0, z: 1.0))
        // let projection = mat4s.identity
        // let projection = mat4s(perspectiveFieldOfViewY: .pi / 4.0, aspectRatio: Float(bounds.size.width) / Float(bounds.size.height), near: 0.1, far: 10.0)
        let projection = window.projectionMatrix
        return (model: model, view: view, projection: projection)
    }()

    lazy var transformTimer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned self] _ in
        if let view = self.window.subviews.first?.subviews.first?.subviews.first {
            let bounds = view.bounds
            let center = view.center

            var mat: mat4s = .identity
            mat = mat * mat4s(translationVector: vec3s(x: center.x, y: center.y, z: 0.0))
            mat = mat * view.transform.mat4
            mat = mat * mat4s(translationVector: vec3s(x: -center.x, y: -center.y, z: 0.0))
            
            self.object.model = mat

            // self.object.model = view.transformToWindow.mat4

            // self.object.view = .identity
            //     // * mat4s(translationVector: vec3s(x: -bounds.minX, y: -bounds.minY, z: 0.0))
            //     // * mat4s(translationVector: vec3s(x: -bounds.width * 0.5, y: -bounds.height * 0.5, z: 0.0))
            //     * mat4s(translationVector: vec3s(x: center.x, y: center.y, z: 0.0))
            //     * mat4s(rotationAngle: self.angle, axis: vec3s(x: 0.0, y: 0.0, z: 1.0))
            //     * mat4s(translationVector: vec3s(x: -center.x, y: -center.y, z: 0.0))
            // // * mat4s(translationVector: vec3s(x: bounds.width * 0.5, y: bounds.height * 0.5, z: 0.0))
            // // * mat4s(translationVector: vec3s(x: bounds.minX, y: bounds.minY, z: 0.0))
        }
    }

    func update(uniformBuffer: Buffer) throws {
        try withUnsafePointer(to: object) {
            try uniformBuffer.memoryChunk.write(data: UnsafeBufferPointer(start: $0, count: 1))
        }
    }

    func addVertices(for view: View, verticesStore: inout [VertexDescriptor], indexStore: inout [Int]) {
        // let vertices = view.vertices
        
        view.subviews.forEach { subview in
            addVertices(for: subview, verticesStore: &verticesStore, indexStore: &indexStore)
        }
    }
}

typealias Transform = (model: mat4s, view: mat4s, projection: mat4s)
typealias UniformBufferObject = (model: mat4s, view: mat4s, projection: mat4s)

fileprivate extension Window {
    var projectionMatrix: mat4s {
        return
            mat4s(scaleVector: vec3s(x: bounds.width != 0 ? 2.0 / bounds.width : 1.0, y: bounds.height != 0 ? 2.0 / bounds.height : 1.0, z: 1.0))
            * mat4s(translationVector: vec3s(x: -bounds.width * 0.5, y: -bounds.height * 0.5, z: 1.0))
            * mat4s(scaleVector: vec3s(x: contentScaleFactor, y: contentScaleFactor, z: contentScaleFactor))
    }
}

fileprivate extension CGColor {
    var vec3: vec3s {
        vec3s(r: red, g: green, b: blue)
    }
    
    var vec4: vec4s {
        vec4s(r: red, g: green, b: blue, a: alpha)
    }
}

fileprivate extension View {
    var vertices: [VertexDescriptor] {
        let color = backgroundColor.vec4
        let center = self.center
        let bounds = self.bounds

        let topLeft = VertexDescriptor(position: vec2s(center.x - bounds.width * 0.5, center.y - bounds.height * 0.5),
                                       color: color,
                                       textureCoordinates: vec2s(x: 0.0, y: 0.0),
                                       transform: .identity)

        let bottomRight = VertexDescriptor(position: vec2s(center.x + bounds.width * 0.5, center.y + bounds.height * 0.5),
                                           color: color,
                                           textureCoordinates: vec2s(x: 1.0, y: 1.0),
                                           transform: .identity)

        let bottomLeft = VertexDescriptor(position: vec2s(center.x - bounds.width * 0.5, center.y + bounds.height * 0.5),
                                          color: color,
                                          textureCoordinates: vec2s(x: 0.0, y: 1.0),
                                          transform: .identity)

        let topRight = VertexDescriptor(position: vec2s(center.x + bounds.width * 0.5, center.y - bounds.height * 0.5),
                                        color: color,
                                        textureCoordinates: vec2s(x: 1.0, y: 0.0),
                                        transform: .identity)

        return [topLeft, bottomRight, bottomLeft, topRight]
    }
}

struct VertexDescriptor {
    var position: vec2s = .zero
    var color: vec4s = .zero
    var textureCoordinates: vec2s = .zero
    var transform: mat4s = .identity
    var borderWidth: Float = .zero
    var borderColor: vec4s = .zero
    var cornerRadius: Float = .zero
}

extension VertexDescriptor: VertexInput {
    static func inputBindingDescription(binding: CUnsignedInt = 0) -> VkVertexInputBindingDescription {
        var result = VkVertexInputBindingDescription()
        result.binding = 0
        result.stride = CUnsignedInt(MemoryLayout<VertexDescriptor>.stride)
        result.inputRate = .vertex

        return result
    }

    static func attributesDescriptions(binding: CUnsignedInt = 0) -> [VkVertexInputAttributeDescription] {
        var result: [VkVertexInputAttributeDescription] = []

        result += attributesDescriptions(for: \.position, binding: binding, location: 0)
        result += attributesDescriptions(for: \.color, binding: binding, location: 1)
        result += attributesDescriptions(for: \.textureCoordinates, binding: binding, location: 2)
        result += attributesDescriptions(for: \.transform, binding: binding, location: 3)
        result += attributesDescriptions(for: \.borderWidth, binding: binding, location: 7)
        result += attributesDescriptions(for: \.borderColor, binding: binding, location: 8)
        result += attributesDescriptions(for: \.cornerRadius, binding: binding, location: 9)

        return result
    }
}

internal extension VkPipelineColorBlendAttachmentState {
    static let rgbaBlend: VkPipelineColorBlendAttachmentState = {
        var colorBlendAttachment = VkPipelineColorBlendAttachmentState()

        colorBlendAttachment.colorComponentMask = .rgba
        colorBlendAttachment.blendEnabled = true
        colorBlendAttachment.srcColorBlendFactor = .sourceAlpha
        colorBlendAttachment.dstColorBlendFactor = .oneMinusSourceAlpha
        colorBlendAttachment.colorBlendOp = .add
        colorBlendAttachment.srcAlphaBlendFactor = .one
        colorBlendAttachment.dstAlphaBlendFactor = .zero
        colorBlendAttachment.alphaBlendOp = .add

        return colorBlendAttachment
    }()

    static let rgbaFlat: VkPipelineColorBlendAttachmentState = {
        var colorBlendAttachment = VkPipelineColorBlendAttachmentState()

        colorBlendAttachment.colorComponentMask = .rgba
        colorBlendAttachment.blendEnabled = false
        colorBlendAttachment.srcColorBlendFactor = .one
        colorBlendAttachment.dstColorBlendFactor = .zero
        colorBlendAttachment.colorBlendOp = .add
        colorBlendAttachment.srcAlphaBlendFactor = .one
        colorBlendAttachment.dstAlphaBlendFactor = .zero
        colorBlendAttachment.alphaBlendOp = .add

        return colorBlendAttachment
    }()
}
