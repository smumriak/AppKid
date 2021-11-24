//
//  VolcanoRenderer.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 18.07.2021.
//

import Foundation
import CoreFoundation
@_spi(AppKid) import Volcano
import TinyFoundation
import CVulkan
import SimpleGLM
import CairoGraphics
import CXlib
import SwiftXlib
import LayerRenderingData

#if os(macOS)
    import struct CairoGraphics.CGColor
    import class CairoGraphics.CGImage
#endif

public func measure(_ label: String, _ block: () throws -> Void) rethrows {
    let start = DispatchTime.now().uptimeNanoseconds
    defer {
        let end = DispatchTime.now().uptimeNanoseconds

        let result = (end - start) / 1000
        if result >= 1500 {
            debugPrint("Time measure: \(label) took \(result) micro seconds")
        }
    }

    try block()
}

internal class DescriptorSetContainer {
    let device: Device
    let layout: SmartPointer<VkDescriptorSetLayout_T>
    let descriptorSet: VkDescriptorSet

    init(bindings: [VkDescriptorSetLayoutBinding], pool: SmartPointer<VkDescriptorPool_T>, device: Device) throws {
        self.device = device

        layout = try bindings.withUnsafeBufferPointer { bindings in
            var info = VkDescriptorSetLayoutCreateInfo()
            info.sType = .descriptorSetLayoutCreateInfo
            info.bindingCount = CUnsignedInt(bindings.count)
            info.pBindings = bindings.baseAddress!

            return try device.create(with: &info)
        }

        descriptorSet = try withUnsafePointer(to: layout.optionalPointer) { layout in
            var info = VkDescriptorSetAllocateInfo()
            info.sType = .descriptorSetAllocateInfo
            info.descriptorPool = pool.pointer
            info.descriptorSetCount = 1
            info.pSetLayouts = layout

            var result: VkDescriptorSet? = nil

            try vulkanInvoke {
                vkAllocateDescriptorSets(device.handle, &info, &result)
            }

            return result!
        }
    }
}

@_spi(AppKid) public class RenderTargetsCache {
    let lock = NSRecursiveLock()
    var renderTargets: [AnyHashable: RenderTarget] = [:]

    let renderPass: RenderPass
    let clearColor: VkClearValue

    init(renderPass: RenderPass, clearColor: VkClearValue = VkClearValue(color: .clear)) {
        self.renderPass = renderPass
        self.clearColor = clearColor
    }

    public func clear() {
        lock.synchronized {
            renderTargets.removeAll()
        }
    }

    public func existingRenderTarget(for texture: Texture) -> RenderTarget? {
        lock.synchronized {
            let textureIdentifier = ObjectIdentifier(texture)
        
            return renderTargets[textureIdentifier]
        }
    }

    public func createRenderTarget(for texture: Texture) throws -> RenderTarget {
        try lock.synchronized {
            let textureIdentifier = ObjectIdentifier(texture)

            if let result = renderTargets[textureIdentifier] {
                return result
            } else {
                let result = try RenderTarget(renderPass: renderPass, colorAttachment: texture, clearColor: clearColor)

                renderTargets[textureIdentifier] = result

                return result
            }
        }
    }
}

@_spi(AppKid) public class VolcanoRenderer: NSObject {
    enum Error: Swift.Error {
        case noLayer
        case noRenderTarget
    }

    var pixelFormat: VkFormat
    public var frameTime: CFTimeInterval = 0.0
    public let queues: VolcanoRenderStack.Queues
    public private(set) var renderContext: RenderContext1

    public let renderStack: VolcanoRenderStack

    public var device: Device { renderStack.device }

    public fileprivate(set) var renderPass: RenderPass
    internal fileprivate(set) var renderTarget: RenderTarget?

    public let commandPool: CommandPool
    private var _commandBuffer: CommandBuffer!
    public var commandBuffer: CommandBuffer {
        get throws {
            if _commandBuffer == nil {
                _commandBuffer = try commandPool.createCommandBuffer()
            }

            return _commandBuffer!
        }
    }

    @_spi(AppKid) public let renderTargetsCache: RenderTargetsCache

    internal var isRendering: Bool = false

    open var layer: CALayer? = nil

    public init(pixelFormat: VkFormat, commandPool: CommandPool) throws {
        self.renderStack = VolcanoRenderStack.global
        let device = renderStack.device

        self.queues = VolcanoRenderStack.Queues(graphics: renderStack.queues.graphics, transfer: renderStack.queues.transfer)

        self.pixelFormat = pixelFormat
        renderPass = try device.createMainRenderPass(pixelFormat: pixelFormat)

        renderTargetsCache = RenderTargetsCache(renderPass: renderPass)
        let descriptorSetsLayouts = try DescriptorSetsLayouts(device: device)

        let backgroundPipeline = try renderPass.createBackgroundPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection])
        let borderPipeline = try renderPass.createBorderPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection])
        let contentsPipeline = try renderPass.createContentsPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection, descriptorSetsLayouts.contentsSampler])

        let pipelines = RenderContext1.Pipelines(
            background: backgroundPipeline,
            border: borderPipeline,
            contents: contentsPipeline
        )

        renderContext = try RenderContext1(renderStack: renderStack, pipelines: pipelines, descriptorSetsLayouts: descriptorSetsLayouts)
        self.commandPool = commandPool

        super.init()
    }

    // MARK: Public interface

    open func beginFrame(atTime time: TimeInterval) throws {
        frameTime = time
    }

    open func nextFrameTime() -> TimeInterval {
        return 0.0
    }

    open func endFrame() throws {
        frameTime = 0.0

        try renderContext.clear()
        try commandBuffer.reset()
    }

    public func setDestination(_ texture: Texture) throws {
        guard renderTarget?.colorAttachment !== texture else {
            return
        }

        renderTarget = try renderTargetsCache.createRenderTarget(for: texture)

        if pixelFormat != texture.pixelFormat {
            renderPass = try device.createMainRenderPass(pixelFormat: texture.pixelFormat)
            let descriptorSetsLayouts = renderContext.descriptorSetsLayouts

            let backgroundPipeline = try renderPass.createBackgroundPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection])
            let borderPipeline = try renderPass.createBorderPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection])
            let contentsPipeline = try renderPass.createContentsPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection, descriptorSetsLayouts.contentsSampler])

            let pipelines = RenderContext1.Pipelines(
                background: backgroundPipeline,
                border: borderPipeline,
                contents: contentsPipeline
            )

            renderContext = try RenderContext1(renderStack: renderStack, pipelines: pipelines, descriptorSetsLayouts: descriptorSetsLayouts)
        }
    }

    @_spi(AppKid)public func buildRenderOperations() throws {
        guard let layer = layer else {
            throw Error.noLayer
        }

        guard let renderTarget = renderTarget else {
            throw Error.noRenderTarget
        }

        try renderContext.clear()

        let modelViewProjection: RenderContext1.ModelViewProjection = (model: .identity, view: .identity, projection: layer.projectionMatrix)

        renderContext.mainCommandBuffer = try commandBuffer
        renderContext.sceneRenderTarget = renderTarget

        renderContext.add(.updateModelViewProjection(modelViewProjection: modelViewProjection))

        renderContext.add(.begineScene())

        var index: UInt = 0

        try traverseLayerTree(for: layer, parentTransform: .identity, index: &index, renderContext: renderContext)

        renderContext.add(.endScene())
    }

    @_spi(AppKid) public func performRenderOperations() throws {
        try renderContext.performOperations()
    }

    @_spi(AppKid) public func submitCommandBuffer(waitSemaphores: [Volcano.Semaphore] = [], signalSemaphores: [Volcano.Semaphore] = [], signalTimelineSemaphores: [TimelineSemaphore] = [], fence: Fence? = nil) throws {
        let descriptor = try SubmitDescriptor(commandBuffers: [commandBuffer], fence: fence)
        try waitSemaphores.forEach {
            try descriptor.add(.wait($0, stages: .colorAttachmentOutput))
        }

        try signalSemaphores.forEach {
            try descriptor.add(.signal($0))
        }

        try signalTimelineSemaphores.forEach {
            try descriptor.add(.signal($0))
        }

        if renderContext.vertexBufferCopyCount > 0 {
            try descriptor.add(.wait(renderContext.vertexBufferCopySemaphore, value: renderContext.vertexBufferCopyCount, stages: .vertexInput))
        }

        try renderContext.graphicsQueue.submit(with: descriptor)
    }

    public func render(waitSemaphores: [Volcano.Semaphore] = [], signalSemaphores: [Volcano.Semaphore] = [], fence: Fence? = nil) throws {
        guard isRendering == false else {
            return
        }

        isRendering = true
        defer { isRendering = false }

        // let startTime = CFAbsoluteTimeGetCurrent()
        try buildRenderOperations()

        // debugPrint("Draw frame start: \(startTime)")

        try performRenderOperations()

        try submitCommandBuffer(waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, fence: fence)

        // let endTime = CFAbsoluteTimeGetCurrent()
        // debugPrint("Draw frame end: \(endTime)")
        // debugPrint("Frame draw took \((endTime - startTime) * 1000.0) ms")
    }

    fileprivate func traverseLayerTree(for layer: CALayer, parentTransform: mat4s, index: inout UInt, renderContext: RenderContext1) throws {
        if layer.isHidden || layer.opacity <= 0.01 {
            return
        }

        let currentLayerIndex = index
        let bounds = layer.bounds
        let position = layer.position
        let anchorPoint = layer.anchorPoint
        let contentsScale = layer.contentsScale

        // let needsOffscreenRendering = layer.needsOffscreenRendering
        let needsDisplay = layer.needsDisplay

        if needsDisplay {
            layer.display()
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
                                               masksToBounds: layer.masksToBounds ? 1 : 0,
                                               shadowOffset: layer.shadowOffset.vec2,
                                               shadowColor: layer.shadowColor?.vec4 ?? .zero,
                                               shadowRadius: Float(layer.shadowRadius),
                                               shadowOpacity: Float(layer.shadowOpacity),
                                               padding0: .zero,
                                               padding1: .zero)

        renderContext.descriptors.append(descriptor)

        renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
        renderContext.add(.background())

        var contentsTexture: Texture? = nil

        switch layer.contents {
            case .some(_ as CGImage):
                break

            case .some(let backingStore as CABackingStore):
                contentsTexture = backingStore.currentTexture

                if contentsTexture == nil {
                    contentsTexture = try backingStore.makeTexture(renderStack: renderStack, graphicsQueue: renderContext.graphicsQueue, commandPool: renderContext.commandPool)

                    backingStore.currentTexture = contentsTexture
                }

            default:
                break
        }

        if let contentsTexture = contentsTexture {
            renderContext.add(.contents(texture: contentsTexture, layerIndex: index))
        }

        try layer.sublayers?.forEach {
            index += 1
            try traverseLayerTree(for: $0, parentTransform: layerLocalTransform, index: &index, renderContext: renderContext)
        }

        if layer.borderWidth > 0 && layer.borderColor != nil {
            renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
            renderContext.add(.border())
        }
    }
}

public extension VolcanoRenderer {
    static func == (lhs: VolcanoRenderer, rhs: VolcanoRenderer) -> Bool { lhs === rhs }
}

internal typealias Transform = (model: mat4s, view: mat4s, projection: mat4s)

internal extension CALayer {
    var projectionMatrix: mat4s {
        return .orthographic(left: 0.0, right: bounds.width * contentsScale, bottom: 0.0, top: bounds.height * contentsScale, near: -1.0, far: 1.0)
    }
}

internal extension CGColor {
    var vec3: vec3s {
        vec3s(r: red, g: green, b: blue)
    }
    
    var vec4: vec4s {
        vec4s(r: red, g: green, b: blue, a: alpha)
    }
}

extension LayerRenderDescriptor: VertexInput {
    public static func inputBindingDescription(binding: CUnsignedInt = 0) -> VkVertexInputBindingDescription {
        var result = VkVertexInputBindingDescription()
        result.binding = 0
        result.stride = CUnsignedInt(MemoryLayout<Self>.stride)
        result.inputRate = .instance

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

internal extension RenderPass {
    func createBackgroundPipeline(subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout]) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try device.shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try device.shader(named: "BackgroundFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

        let descriptor = GraphicsPipelineDescriptor()
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        descriptor.descriptorSetLayouts = descriptorSetLayouts
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

        return try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: self, subpassIndex: subpassIndex)
    }

    func createBorderPipeline(subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout]) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try device.shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try device.shader(named: "BorderFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

        let descriptor = GraphicsPipelineDescriptor()
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        descriptor.descriptorSetLayouts = descriptorSetLayouts

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

        return try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: self, subpassIndex: subpassIndex)
    }

    func createContentsPipeline(subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout]) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try device.shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try device.shader(named: "ContentsFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

        let descriptor = GraphicsPipelineDescriptor()
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        descriptor.descriptorSetLayouts = descriptorSetLayouts

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

        return try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: self, subpassIndex: subpassIndex)
    }
}

internal extension Device {
    func createMainRenderPass(pixelFormat: VkFormat) throws -> RenderPass {
        var colorAttachmentDescription = VkAttachmentDescription()
        colorAttachmentDescription.format = pixelFormat
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
}
