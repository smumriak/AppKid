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

public protocol VulkanRendererDelegate: AnyObject {
    func didBeginRenderingFrame(renderer: VulkanRenderer)
    func didEndRenderingFrame(renderer: VulkanRenderer)
}

public final class VulkanRenderer: NSObject {
    internal var window: AppKid.Window {
        didSet {
            try? render()
        }
    }

    internal let queues: VulkanRenderContext.Queues
    internal let pipelines: VulkanRenderContext.Pipelines
    internal let renderContext: VulkanRenderContext
    internal fileprivate(set) var presentationQueue: Queue

    public weak var delegate: VulkanRendererDelegate? = nil

    internal fileprivate(set) var renderStack: VulkanRenderStack

    internal var device: Device { renderStack.device }
    
    internal fileprivate(set) var surface: Surface


    internal fileprivate(set) var imageAvailableSemaphore: Volcano.Semaphore
    internal fileprivate(set) var renderFinishedSemaphore: Volcano.Semaphore
    internal fileprivate(set) var fence: Fence
    internal fileprivate(set) var renderPass: RenderPass

    var oldSwapchain: Swapchain?
    var swapchain: Swapchain!
    var renderTargets: [VulkanRenderTarget] = []

    var pipeline: GraphicsPipeline!
    var commandBuffers: [CommandBuffer] = []
    var vertexBuffer: Buffer!

    var uniformBuffers: [Buffer] = []
    var descriptorPool: SmartPointer<VkDescriptorPool_T>!
    var descriptorSets: [VkDescriptorSet] = []

    deinit {
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

        guard let transferQueue = device.allQueues.first(where: { $0.type.contains(.transfer) }) else {
            throw VulkanRendererError.noTransferQueueFound
        }

        imageAvailableSemaphore = try Semaphore(device: device)
        renderFinishedSemaphore = try Semaphore(device: device)
        fence = try Fence(device: device)

        renderPass = try device.createMainRenderPasss(format: surface.imageFormat)
        pipeline = try device.createBackgroundPipeline(renderPass: renderPass)

        let queues = VulkanRenderContext.Queues(graphics: graphicsQueue, transfer: transferQueue)
        let pipelines = VulkanRenderContext.Pipelines(background: pipeline)
        
        self.queues = queues
        self.pipelines = pipelines

        renderContext = try VulkanRenderContext(renderStack: renderStack, queues: queues, pipelines: pipelines)

        super.init()
    }

    public func setupSwapchain() throws {
        let windowSize = window.bounds.size
        let displayScale = window.nativeWindow.displayScale
        let desiredSize = VkExtent2D(width: UInt32(windowSize.width * displayScale), height: UInt32(windowSize.height * displayScale))
        
        try surface.refreshCapabilities()
        let capabilities = surface.capabilities
        let minSize = capabilities.minImageExtent
        let maxSize = capabilities.maxImageExtent

        let width = max(min(desiredSize.width, maxSize.width), minSize.width)
        let height = max(min(desiredSize.height, maxSize.height), minSize.height)
        let size = VkExtent2D(width: width, height: height)

        swapchain = try Swapchain(device: device, surface: surface, desiredPresentMode: .immediate, size: size, graphicsQueue: queues.graphics, presentationQueue: presentationQueue, usage: .colorAttachment, compositeAlpha: .opaque, oldSwapchain: oldSwapchain)
        renderTargets = try swapchain.textures.map {
            try VulkanRenderTarget(renderPass: renderPass, colorAttachment: $0, clearColor: VkClearValue(color: .red))
        }

        uniformBuffers = try createUniformBuffers()

        descriptorPool = try createDescriptorPool()
        descriptorSets = try createDescriptorSets()
        
        oldSwapchain = nil
    }

    public func clearSwapchain() throws {
        try device.waitForIdle()

        oldSwapchain = swapchain

        commandBuffers.removeAll()
        uniformBuffers.removeAll()
        descriptorSets.removeAll()
        descriptorPool = nil
        renderTargets.removeAll()
        swapchain = nil
    }

    public func beginFrame() {
        delegate?.didBeginRenderingFrame(renderer: self)
    }

    public func endFrame() {
        delegate?.didEndRenderingFrame(renderer: self)
    }

    public func render() throws {
        beginFrame()
        defer { endFrame() }

        // trying to recreate swapchain only once per render request. if it fails for the second time - frame is skipped assuming there will be new render request following. maybe not the best thing to do because it's like a hidden logic. will re-evaluate
        var skipRecreation = false

        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        while true {
            do {
                object.projection = window.projectionMatrix

                try drawFrameWithOperations()

                break
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDate {
                    if skipRecreation == true {
                        break
                    }

                    try clearSwapchain()                    
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
        //palkovnik:Disabled this logic for now since recreating swapchain on error gives better performance results
        // do {
        //     try clearSwapchain()

        //     vertexBuffer = try createVertexBuffer()

        //     try setupSwapchain()
        // } catch {
        //     debugPrint("Failed to recreate swapchain with error: \(error)")
        // }
    }

    func drawFrameWithOperations() throws {
        // let startTime = CFAbsoluteTimeGetCurrent()
        // debugPrint("Draw frame start: \(startTime)")
        try fence.reset()

        try renderContext.clear()

        renderContext.add(.pushCommandBuffer())

        let imageIndex = try swapchain.getNextImageIndex(semaphore: imageAvailableSemaphore)
        try self.update(uniformBuffer: uniformBuffers[imageIndex])
        let renderTarget = renderTargets[imageIndex]
        
        renderContext.add(.pushRenderTarget(renderTarget: renderTarget))

        var index: UInt32 = 0

        try traverseLayerTree(for: window.layer, parentTransform: .identity, index: &index, renderContext: renderContext, descriptorSets: [descriptorSets[imageIndex]])

        renderContext.add(.popRenderTarget(rebind: false))

        let waitSemaphores: [Volcano.Semaphore] = [imageAvailableSemaphore]
        let signalSemaphores: [Volcano.Semaphore] = [renderFinishedSemaphore]
        let waitStages: [VkPipelineStageFlags] = [VkPipelineStageFlagBits.colorAttachmentOutput.rawValue]

        renderContext.add(.submitCommandBuffer(waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, waitStages: waitStages, fence: fence))
        renderContext.add(.wait(fence: fence))
        renderContext.add(.popCommandBuffer())

        try renderContext.performOperations()

        try presentationQueue.present(swapchains: [swapchain], waitSemaphores: signalSemaphores, imageIndices: [CUnsignedInt(imageIndex)])

        // let endTime = CFAbsoluteTimeGetCurrent()
        // debugPrint("Draw frame end: \(endTime)")
        // debugPrint("Frame draw took \((endTime - startTime) * 1000.0) ms")
    }

    fileprivate func traverseLayerTree(for layer: CALayer, parentTransform: mat4s, index: inout UInt32, renderContext: VulkanRenderContext, descriptorSets: [VkDescriptorSet]? = nil) throws {
        let bounds = layer.bounds
        let position = layer.position
        let anchorPoint = layer.anchorPoint
        let contentsScale = layer.contentsScale

        let needsOffscreenRendering = layer.needsOffscreenRendering

        if needsOffscreenRendering {
            let backingStore: CABackingStore = try {
                if let result = layer.backingStore, result.fits(size: layer.bounds.size) {
                    return result
                } else {
                    let result = try CABackingStore(size: layer.bounds.size, device: renderStack.device)
                    layer.backingStore = result
                    return result
                }
            }()
        }

        let toScreenScaleTransform = mat4s(scaleVector: vec3s(x: bounds.width * contentsScale, y: bounds.height * contentsScale, z: 1.0))
        let anchorPointTransform = mat4s(translationVector: vec3s(x: anchorPoint.x * bounds.width * contentsScale, y: anchorPoint.y * bounds.height * contentsScale, z: 0.0))

        let positionTransform = mat4s(translationVector: vec3s(x: (position.x - bounds.midX) * contentsScale, y: (position.y - bounds.midY) * contentsScale, z: 0.0))

        let layerLocalTransform =
            parentTransform
                * positionTransform
                * anchorPointTransform
                * layer.transform.mat4
                * anchorPointTransform.inversed

        let layerScreenTransform = layerLocalTransform * toScreenScaleTransform

        let descriptor = LayerRenderDescriptor(transform: layerScreenTransform,
                                               contentsTransform: layerScreenTransform,
                                               position: position.vec2,
                                               anchorPoint: layer.anchorPoint.vec2,
                                               bounds: bounds.vec4,
                                               backgroundColor: layer.backgroundColor?.vec4 ?? .zero,
                                               borderColor: layer.borderColor?.vec4 ?? .zero,
                                               borderWidth: Float(layer.borderWidth),
                                               cornerRadius: Float(layer.cornerRadius),
                                               shadowOffset: layer.shadowOffset.vec2,
                                               shadowColor: layer.shadowColor?.vec4 ?? .zero,
                                               shadowRadius: Float(layer.shadowRadius),
                                               shadowOpacity: Float(layer.shadowOpacity))

        renderContext.descriptors.append(descriptor)

        renderContext.add(.bindVertexBuffer(index: index))

        renderContext.add(.background(descriptorSets: descriptorSets))

        try layer.sublayers?.forEach {
            index += 1
            try traverseLayerTree(for: $0, parentTransform: layerLocalTransform, index: &index, renderContext: renderContext, descriptorSets: descriptorSets)
        }
    }

    func createUniformBuffers() throws -> [Buffer] {
        let size = VkDeviceSize(MemoryLayout<UniformBufferObject>.size)
        return try renderTargets.indices.map { _ in
            let result = try Buffer(device: device,
                                    size: size,
                                    usage: [.uniformBuffer],
                                    memoryProperties: [.hostVisible, .hostCoherent],
                                    accessQueues: [queues.graphics, queues.transfer])

            try update(uniformBuffer: result)
            return result
        }
    }

    func createDescriptorPool() throws -> SmartPointer<VkDescriptorPool_T> {
        var poolSize = VkDescriptorPoolSize()
        poolSize.type = .uniformBuffer
        poolSize.descriptorCount = CUnsignedInt(renderTargets.count)

        let sizes = [poolSize]

        return try sizes.withUnsafeBufferPointer { sizes in
            var info = VkDescriptorPoolCreateInfo()
            info.sType = .descriptorPoolCreateInfo
            info.poolSizeCount = CUnsignedInt(sizes.count)
            info.pPoolSizes = sizes.baseAddress!
            info.maxSets = CUnsignedInt(renderTargets.count)

            return try device.create(with: &info)
        }
    }

    func createDescriptorSets() throws -> [VkDescriptorSet] {
        let count = renderTargets.count
        let layouts: [VkDescriptorSetLayout?] = Array<SmartPointer<VkDescriptorSetLayout_T>>(repeating: pipeline.descriptorSetLayouts[0], count: count).map { $0.pointer }

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
        let projection = mat4s.identity
        // let projection = mat4s(perspectiveFieldOfViewY: .pi / 4.0, aspectRatio: Float(bounds.size.width) / Float(bounds.size.height), near: 0.1, far: 10.0)
        // let projection = window.projectionMatrix
        return (model: model, view: view, projection: projection)
    }()

    func update(uniformBuffer: Buffer) throws {
        try withUnsafePointer(to: object) {
            try uniformBuffer.memoryChunk.write(data: UnsafeBufferPointer(start: $0, count: 1))
        }
    }
}

public extension VulkanRenderer {
    static func == (lhs: VulkanRenderer, rhs: VulkanRenderer) -> Bool { lhs === rhs }
}

typealias Transform = (model: mat4s, view: mat4s, projection: mat4s)
typealias UniformBufferObject = (model: mat4s, view: mat4s, projection: mat4s)

fileprivate extension Window {
    var projectionMatrix: mat4s {
        return .orthographic(left: 0.0, right: bounds.width * contentScaleFactor, bottom: 0.0, top: bounds.height * contentScaleFactor, near: -1.0, far: 1.0)
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

// align each field by 16
struct LayerRenderDescriptor {
    var transform: mat4s = .identity // +64 bytes
    var contentsTransform: mat4s = .identity // +64 bytes
    var position: vec2s = .zero // +8 bytes
    var anchorPoint: vec2s = .zero // +8 bytes
    var bounds: vec4s = .zero // +16 bytes
    var backgroundColor: vec4s = .zero // +16 bytes
    var borderColor: vec4s = .zero // +16 bytes
    var borderWidth: Float = .zero // +4 bytes
    var cornerRadius: Float = .zero // +4 bytes
    var shadowOffset: vec2s = .zero // +8 bytes
    var shadowColor: vec4s = .zero // +16 bytes
    var shadowRadius: Float = .zero // +4 bytes
    var shadowOpacity: Float = .zero // +4 bytes

    // Totoal before padding: 232 bytes

    var padding0: vec2s = .zero // + 8 bytes
    var padding1: vec4s = .zero // +16 bytes

    // Total: 256 bytes
}

extension LayerRenderDescriptor: VertexInput {
    static func inputBindingDescription(binding: CUnsignedInt = 0) -> VkVertexInputBindingDescription {
        var result = VkVertexInputBindingDescription()
        result.binding = 0
        result.stride = CUnsignedInt(MemoryLayout<Self>.stride)
        result.inputRate = .instance

        return result
    }

    static func attributesDescriptions(binding: CUnsignedInt = 0) -> [VkVertexInputAttributeDescription] {
        var result: [VkVertexInputAttributeDescription] = []

        addAttributes(for: \.transform, binding: binding, result: &result)
        addAttributes(for: \.contentsTransform, binding: binding, result: &result)
        addAttributes(for: \.position, binding: binding, result: &result)
        addAttributes(for: \.anchorPoint, binding: binding, result: &result)
        addAttributes(for: \.bounds, binding: binding, result: &result)
        addAttributes(for: \.backgroundColor, binding: binding, result: &result)
        addAttributes(for: \.borderColor, binding: binding, result: &result)
        addAttributes(for: \.borderWidth, binding: binding, result: &result)
        addAttributes(for: \.cornerRadius, binding: binding, result: &result)
        addAttributes(for: \.shadowOffset, binding: binding, result: &result)
        addAttributes(for: \.shadowColor, binding: binding, result: &result)
        addAttributes(for: \.shadowRadius, binding: binding, result: &result)
        addAttributes(for: \.shadowOpacity, binding: binding, result: &result)

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

internal extension Device {
    func createMainRenderPasss(format: VkFormat = .rgba8UNorm) throws -> RenderPass {
        var colorAttachmentDescription = VkAttachmentDescription()
        colorAttachmentDescription.format = format
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

        return try RenderPass(device: self, subpasses: [subpass1], dependencies: [dependency1])
    }

    func createBackgroundPipeline(renderPass: RenderPass, subpassIndex: Int = 0) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try shader(named: "BackgroundDrawVertexShader", in: bundle)
        let fragmentShader = try shader(named: "BackgroundDrawFragmentShader", in: bundle)

        var descriptorSetLayoutBinding = VkDescriptorSetLayoutBinding()
        descriptorSetLayoutBinding.binding = 0
        descriptorSetLayoutBinding.descriptorType = .uniformBuffer
        descriptorSetLayoutBinding.descriptorCount = 1
        descriptorSetLayoutBinding.stageFlags = VkShaderStageFlagBits.vertex.rawValue
        descriptorSetLayoutBinding.pImmutableSamplers = nil

        let descriptorSetLayoutBindings = [descriptorSetLayoutBinding]

        let descriptorSetLayout: SmartPointer<VkDescriptorSetLayout_T> = try descriptorSetLayoutBindings.withUnsafeBufferPointer { descriptorSetLayoutBindings in
            var info = VkDescriptorSetLayoutCreateInfo()
            info.sType = .descriptorSetLayoutCreateInfo
            info.bindingCount = CUnsignedInt(descriptorSetLayoutBindings.count)
            info.pBindings = descriptorSetLayoutBindings.baseAddress!

            return try create(with: &info)
        }

        let descriptor = GraphicsPipelineDescriptor()
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        descriptor.descriptorSetLayouts = [descriptorSetLayout]

        descriptor.viewportState = .dynamic(viewportsCount: 1, scissorsCount: 1)

        descriptor.vertexInputBindingDescriptions = [LayerRenderDescriptor.inputBindingDescription()]
        descriptor.inputAttributeDescrioptions = LayerRenderDescriptor.attributesDescriptions()

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

        return try GraphicsPipeline(device: self, descriptor: descriptor, renderPass: renderPass, subpassIndex: subpassIndex)
    }
}
