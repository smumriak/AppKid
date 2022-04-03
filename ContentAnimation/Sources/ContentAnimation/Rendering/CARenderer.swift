//
//  CARenderer.swift
//  ContentAnimation
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
import LayerRenderingData

#if os(macOS)
    import struct CairoGraphics.CGColor
    import class CairoGraphics.CGImage
#endif

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
    internal var renderContext: RenderContext
    internal let commandPool: CommandPool
    internal let commandBuffer: CommandBuffer

    public fileprivate(set) var texture: Texture
    internal let renderStack: VolcanoRenderStack

    internal var device: Device { renderStack.device }

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

        fence = try Fence(device: device)

        renderPass = try device.createMainRenderPass(pixelFormat: texture.pixelFormat)

        renderTarget = try RenderTarget(renderPass: renderPass, colorAttachment: texture, resolveAttachment: texture, clearColor: VkClearValue(color: .red))

        descriptorSetsLayouts = try DescriptorSetsLayouts(device: device)

        let backgroundPipelineAntiAliased = try renderPass.createBackgroundPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: true)
        let backgroundPipelineNotAntiAliased = try renderPass.createBackgroundPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: false)
        let borderPipelineAntiAliased = try renderPass.createBorderPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: true)
        let borderPipelineNotAntiAliased = try renderPass.createBorderPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: false)
        let contentsPipelineAntiAliased = try renderPass.createContentsPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection, descriptorSetsLayouts.contentsSampler], antiAliased: true)
        let contentsPipelineNotAntiAliased = try renderPass.createContentsPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection, descriptorSetsLayouts.contentsSampler], antiAliased: false)

        let pipelines = RenderContext.Pipelines(
            backgroundAntiAliased: backgroundPipelineAntiAliased,
            backgroundNotAntiAliased: backgroundPipelineNotAntiAliased,
            borderAntiAliased: borderPipelineAntiAliased,
            borderNotAntiAliased: borderPipelineNotAntiAliased,
            contentsAntiAliased: contentsPipelineAntiAliased,
            contentsNotAntiAliased: contentsPipelineNotAntiAliased
        )
        
        renderContext = try RenderContext(renderStack: renderStack, pipelines: pipelines, descriptorSetsLayouts: descriptorSetsLayouts)
        
        commandPool = try renderStack.queues.graphics.createCommandPool(flags: .resetCommandBuffer)
        commandBuffer = try commandPool.createCommandBuffer()

        super.init()
    }

    // MARK: - Public interface

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

    public func setDestination(_ texture: Texture) throws {
        guard self.texture !== texture else {
            return
        }
        
        self.texture = texture

        renderPass = try device.createMainRenderPass(pixelFormat: texture.pixelFormat)
        renderTarget = try RenderTarget(renderPass: renderPass, colorAttachment: texture, resolveAttachment: texture, clearColor: VkClearValue(color: .red))
        let backgroundPipelineAntiAliased = try renderPass.createBackgroundPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: true)
        let backgroundPipelineNotAntiAliased = try renderPass.createBackgroundPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: false)
        let borderPipelineAntiAliased = try renderPass.createBorderPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: true)
        let borderPipelineNotAntiAliased = try renderPass.createBorderPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection], antiAliased: false)
        let contentsPipelineAntiAliased = try renderPass.createContentsPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection, descriptorSetsLayouts.contentsSampler], antiAliased: true)
        let contentsPipelineNotAntiAliased = try renderPass.createContentsPipeline(descriptorSetLayouts: [descriptorSetsLayouts.modelViewProjection, descriptorSetsLayouts.contentsSampler], antiAliased: false)

        let pipelines = RenderContext.Pipelines(
            backgroundAntiAliased: backgroundPipelineAntiAliased,
            backgroundNotAntiAliased: backgroundPipelineNotAntiAliased,
            borderAntiAliased: borderPipelineAntiAliased,
            borderNotAntiAliased: borderPipelineNotAntiAliased,
            contentsAntiAliased: contentsPipelineAntiAliased,
            contentsNotAntiAliased: contentsPipelineNotAntiAliased
        )

        renderContext = try RenderContext(renderStack: renderStack, pipelines: pipelines, descriptorSetsLayouts: descriptorSetsLayouts)
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

        try fence.reset()

        try renderContext.clear()

        let modelViewProjection: RenderContext.ModelViewProjection = (model: .identity, view: .identity, projection: layer.projectionMatrix)

        renderContext.mainCommandBuffer = commandBuffer
        renderContext.sceneRenderTarget = renderTarget

        renderContext.add(.updateModelViewProjection(modelViewProjection: modelViewProjection))

        renderContext.add(.begineScene())

        renderContext.add(.pushRenderTarget(renderTarget))

        var index: UInt = 0

        try traverseLayerTree(for: layer, parentTransform: .identity, index: &index, renderContext: renderContext)

        renderContext.add(.endScene())

        try renderContext.performOperations()

        let descriptor = SubmitDescriptor(commandBuffers: [commandBuffer], fence: fence)
        try waitSemaphores.forEach {
            try descriptor.add(.wait($0, stages: .colorAttachmentOutput))
        }

        try signalSemaphores.forEach {
            try descriptor.add(.signal($0))
        }

        if renderContext.vertexBufferCopyCount > 0 {
            try descriptor.add(.wait(renderContext.vertexBufferCopySemaphore, value: renderContext.vertexBufferCopyCount, stages: .vertexInput))
        }

        try renderContext.graphicsQueue.submit(with: descriptor)

        try fence.wait()
        try fence.reset()
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
        renderContext.add(.background(antiAliased: true))

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
            renderContext.add(.contents(texture: contentsTexture, layerIndex: index, antiAliased: false))
        }

        try layer.sublayers?.forEach {
            index += 1
            try traverseLayerTree(for: $0, parentTransform: layerLocalTransform, index: &index, renderContext: renderContext)
        }

        if layer.borderWidth > 0 && layer.borderColor != nil {
            renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
            renderContext.add(.border(antiAliased: true))
        }
    }
}

public extension CARenderer {
    static func == (lhs: CARenderer, rhs: CARenderer) -> Bool { lhs === rhs }
}
