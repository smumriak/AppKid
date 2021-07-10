//
//  CARenderer.swift
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
import CairoGraphics
import CXlib
import SwiftXlib
import LayerRenderingData

#if os(macOS)
    import struct CairoGraphics.CGColor
    import class CairoGraphics.CGImage
#endif

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

internal class DescriptorSetsLayouts {
    let modelViewProjection: DescriptorSetLayout
    let contentsSampler: DescriptorSetLayout

    init(device: Device) throws {
        var modelViewProjectionBinding = VkDescriptorSetLayoutBinding()
        modelViewProjectionBinding.binding = 0
        modelViewProjectionBinding.descriptorType = .uniformBuffer
        modelViewProjectionBinding.descriptorCount = 1
        modelViewProjectionBinding.stages = .vertex
        modelViewProjectionBinding.pImmutableSamplers = nil

        modelViewProjection = try DescriptorSetLayout(device: device, bindings: [modelViewProjectionBinding])

        var contentsSamplerBinding = VkDescriptorSetLayoutBinding()
        contentsSamplerBinding.binding = 0
        contentsSamplerBinding.descriptorType = .combinedImageSampler
        contentsSamplerBinding.descriptorCount = 1
        contentsSamplerBinding.stages = .fragment
        contentsSamplerBinding.pImmutableSamplers = nil

        contentsSampler = try DescriptorSetLayout(device: device, bindings: [contentsSamplerBinding])
    }
}

open class CARenderer: NSObject {
    internal var frameTime: CFTimeInterval = 0.0
    internal let queues: VolcanoRenderStack.Queues
    internal let pipelines: RenderContext.Pipelines
    internal let renderContext: RenderContext

    public fileprivate(set) var texture: Texture
    internal let renderStack: VolcanoRenderStack

    internal var device: Device { renderStack.device }

    internal fileprivate(set) var renderFinishedSemaphore: Volcano.Semaphore
    @_spi(AppKid) public fileprivate(set) var fence: Fence
    internal fileprivate(set) var renderPass: RenderPass
    internal fileprivate(set) var renderTarget: RenderTarget

    internal fileprivate(set) var descriptorSetsLayouts: DescriptorSetsLayouts

    internal var isRendering: Bool = false

    open var layer: CALayer? = nil

    public init(texture: Texture) throws {
        self.texture = texture
        self.renderStack = VolcanoRenderStack.global
        let device = renderStack.device

        self.queues = VolcanoRenderStack.Queues(graphics: renderStack.queues.graphics, transfer: renderStack.queues.transfer)

        renderFinishedSemaphore = try Semaphore(device: device)
        fence = try Fence(device: device)

        renderPass = try device.createMainRenderPasss(format: texture.pixelFormat)

        renderTarget = try RenderTarget(renderPass: renderPass, colorAttachment: texture, clearColor: VkClearValue(color: .red))

        descriptorSetsLayouts = try DescriptorSetsLayouts(device: device)

        let backgroundPipeline = try device.createBackgroundPipeline(renderPass: renderPass, descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection])
        let borderPipeline = try device.createBorderPipeline(renderPass: renderPass, descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection])
        let contentsPipeline = try device.createContentsPipeline(renderPass: renderPass, descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection, descriptorSetsLayouts.contentsSampler])

        let pipelines = RenderContext.Pipelines(
            background: backgroundPipeline,
            border: borderPipeline,
            contents: contentsPipeline
        )
        
        self.pipelines = pipelines
        
        renderContext = try RenderContext(renderStack: renderStack, pipelines: pipelines, descriptorSetsLayouts: descriptorSetsLayouts)

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
    }

    public func setDestination(_ texture: Texture) {
        self.texture = texture
    }

    public func render(waitSemaphores: [Volcano.Semaphore] = [], signalSemaphores: [Volcano.Semaphore] = []) throws {
        guard let layer = layer else {
            return
        }

        guard isRendering == false else {
            return
        }

        isRendering = true
        defer { isRendering = false }

        if renderTarget.colorAttachment !== texture {
            renderTarget = try RenderTarget(renderPass: renderPass, colorAttachment: texture, clearColor: VkClearValue(color: .red))
        }

        // let startTime = CFAbsoluteTimeGetCurrent()
        // debugPrint("Draw frame start: \(startTime)")
        try fence.reset()

        try renderContext.clear()

        let modelViewProjection: RenderContext.ModelViewProjection = (model: .identity, view: .identity, projection: layer.projectionMatrix)

        renderContext.add(.updateModelViewProjection(modelViewProjection: modelViewProjection))

        renderContext.add(.pushCommandBuffer())

        renderContext.add(.pushRenderTarget(renderTarget: renderTarget))

        var index: UInt = 0

        try traverseLayerTree(for: layer, parentTransform: .identity, index: &index, renderContext: renderContext)

        renderContext.add(.popRenderTarget(rebind: false))

        let waitStages: [VkPipelineStageFlags] = [VkPipelineStageFlagBits.colorAttachmentOutput.rawValue]

        renderContext.add(.submitCommandBuffer(waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, waitStages: waitStages, fence: fence))
        renderContext.add(.wait(fence: fence))
        renderContext.add(.popCommandBuffer())

        try renderContext.performOperations()
        let endTime = CFAbsoluteTimeGetCurrent()
        // debugPrint("Draw frame end: \(endTime)")
        // debugPrint("Frame draw took \((endTime - startTime) * 1000.0) ms")
    }

    fileprivate func traverseLayerTree(for layer: CALayer, parentTransform: mat4s, index: inout UInt, renderContext: RenderContext) throws {
        if layer.isHidden || layer.opacity <= 0.01 {
            return
        }

        let currentLayerIndex = index
        let bounds = layer.bounds
        let position = layer.position
        let anchorPoint = layer.anchorPoint
        let contentsScale = layer.contentsScale

        let needsOffscreenRendering = layer.needsOffscreenRendering
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
            case .some(let image as CGImage):
                break

            case .some(let backingStore as CABackingStore):
                contentsTexture = backingStore.currentTexture

                if contentsTexture == nil {
                    contentsTexture = try backingStore.makeTexture(device: device, graphicsQueue: renderContext.graphicsQueue, commandPool: renderContext.commandPool)

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

public extension CARenderer {
    static func == (lhs: CARenderer, rhs: CARenderer) -> Bool { lhs === rhs }
}

typealias Transform = (model: mat4s, view: mat4s, projection: mat4s)

fileprivate extension CALayer {
    var projectionMatrix: mat4s {
        return .orthographic(left: 0.0, right: bounds.width * contentsScale, bottom: 0.0, top: bounds.height * contentsScale, near: -1.0, far: 1.0)
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

    func createBackgroundPipeline(renderPass: RenderPass, subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout]) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try shader(named: "BackgroundFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

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

        return try GraphicsPipeline(device: self, descriptor: descriptor, renderPass: renderPass, subpassIndex: subpassIndex)
    }

    func createBorderPipeline(renderPass: RenderPass, subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout]) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try shader(named: "BorderFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

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

        return try GraphicsPipeline(device: self, descriptor: descriptor, renderPass: renderPass, subpassIndex: subpassIndex)
    }

    func createContentsPipeline(renderPass: RenderPass, subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout]) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try shader(named: "ContentsFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

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

        return try GraphicsPipeline(device: self, descriptor: descriptor, renderPass: renderPass, subpassIndex: subpassIndex)
    }
}
