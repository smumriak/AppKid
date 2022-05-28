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
@_spi(AppKid) import CairoGraphics
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
            var info = VkDescriptorSetLayoutCreateInfo.new()
            info.bindingCount = CUnsignedInt(bindings.count)
            info.pBindings = bindings.baseAddress!

            return try device.create(with: &info)
        }

        descriptorSet = try withUnsafePointer(to: layout.optionalPointer) { layout in
            var info = VkDescriptorSetAllocateInfo.new()
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

    public func createRenderTarget(forTarget target: Texture, resolve: Texture) throws -> RenderTarget {
        try lock.synchronized {
            let textureIdentifier = ObjectIdentifier(target)

            if let result = renderTargets[textureIdentifier] {
                return result
            } else {
                let result = try RenderTarget(renderPass: renderPass, colorAttachment: target, resolveAttachment: resolve, clearColor: clearColor)

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
    public private(set) var renderContext: RenderContext

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
        self.commandPool = commandPool

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
        try commandBuffer.reset()
    }

    public func setDestination(target: Texture, resolve: Texture) throws {
        guard renderTarget?.colorAttachment !== target else {
            return
        }

        if pixelFormat != target.pixelFormat {
            renderPass = try device.createMainRenderPass(pixelFormat: target.pixelFormat)
            let descriptorSetsLayouts = renderContext.descriptorSetsLayouts

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

        renderTarget = try renderTargetsCache.createRenderTarget(forTarget: target, resolve: resolve)
    }

    @_spi(AppKid) public func buildRenderOperations() throws {
        guard let layer = layer else {
            throw Error.noLayer
        }

        guard let renderTarget = renderTarget else {
            throw Error.noRenderTarget
        }

        try renderContext.clear()

        let modelViewProjection: RenderContext.ModelViewProjection = (model: .identity, view: .identity, projection: layer.projectionMatrix)

        renderContext.mainCommandBuffer = try commandBuffer
        renderContext.sceneRenderTarget = renderTarget

        renderContext.add(.updateModelViewProjection(modelViewProjection: modelViewProjection))

        renderContext.add(.begineScene())

        var index: UInt = 0

        try traverseLayerTree(for: layer, parentTransform: .identity, index: &index, renderContext: renderContext)
        // try traverseLayerTree(for: layer, renderContext: renderContext)

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

        try buildRenderOperations()

        try performRenderOperations()

        try submitCommandBuffer(waitSemaphores: waitSemaphores, signalSemaphores: signalSemaphores, fence: fence)
    }

    internal struct StackValue {
        var layer: CALayer
        var layerIndex: UInt
        var sublayerIndex: Int
    }

    fileprivate func traverseLayerTree(for layer: CALayer, renderContext: RenderContext) throws {
        var stack: [StackValue] = []
        var currentLayerOptional: CALayer? = layer
        var currentLayerIndex: UInt = 0

        while currentLayerOptional != nil || stack.isEmpty == false {
            if let current = currentLayerOptional {
                let bounds = current.bounds
                let position = current.position
                let contentsScale = current.contentsScale

                // let needsOffscreenRendering = current.needsOffscreenRendering
                let needsDisplay = current.needsDisplay

                if needsDisplay {
                    current.display()
                }

                let toScreenScaleTransform = mat4s(scaleVector: vec3s(x: bounds.width * contentsScale, y: bounds.height * contentsScale, z: 1.0))
                // let anchorPointTransform = mat4s(translationVector: vec3s(x: anchorPoint.x * bounds.width * contentsScale, y: anchorPoint.y * bounds.height * contentsScale, z: 0.0))

                // let positionTransform = mat4s(translationVector: vec3s(x: (position.x - bounds.midX) * contentsScale, y: (position.y - bounds.midY) * contentsScale, z: 0.0))

                // let layerLocalTransform =
                //     parentTransform
                //         * positionTransform
                //         * anchorPointTransform
                //         * current.transform.mat4
                //         * anchorPointTransform.inversed

                // let layerScreenTransform = layerLocalTransform * toScreenScaleTransform

                let layerScreenTransform = current.transformToRoot * toScreenScaleTransform

                let descriptor = LayerRenderDescriptor(transform: layerScreenTransform,
                                                       contentsTransform: layerScreenTransform,
                                                       position: position.vec2,
                                                       anchorPoint: current.anchorPoint.vec2,
                                                       bounds: bounds.vec4,
                                                       backgroundColor: current.backgroundColor?.vec4 ?? .zero,
                                                       borderColor: current.borderColor?.vec4 ?? .zero,
                                                       borderWidth: Float(current.borderWidth),
                                                       cornerRadius: Float(current.cornerRadius),
                                                       masksToBounds: current.masksToBounds ? 1 : 0,
                                                       shadowOffset: current.shadowOffset.vec2,
                                                       shadowColor: current.shadowColor?.vec4 ?? .zero,
                                                       shadowRadius: Float(current.shadowRadius),
                                                       shadowOpacity: Float(current.shadowOpacity),
                                                       padding0: .zero,
                                                       padding1: .zero)

                renderContext.descriptors.append(descriptor)

                if let backgroundColor = layer.backgroundColor, backgroundColor.alpha != 0 {
                    renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
                    renderContext.add(.background(antiAliased: true))
                }
        
                let drawableContents: TextureDrawable?

                if needsDisplay {
                    switch layer.contents {
                        case .some(let image as CGImage):
                            drawableContents = image

                        case .some(let backingStore as CABackingStore):
                            backingStore.frontContext.flush()
                            drawableContents = backingStore

                        default:
                            drawableContents = nil
                    }

                    if let drawableContents = drawableContents {
                        if layer.texture == nil || layer.flags.contains(.needsNewTexture) {
                            layer.texture = try drawableContents.createTexture(renderStack: renderStack, graphicsQueue: renderContext.graphicsQueue, commandPool: commandPool)
                            layer.flags.remove(.needsNewTexture)
                        }

                        try drawableContents.drawIn(texture: layer.texture!, graphicsQueue: renderContext.graphicsQueue, commandPool: commandPool)
                    }
                }

                if let layerTexture = layer.texture {
                    renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
                    renderContext.add(.contents(texture: layerTexture, layerIndex: currentLayerIndex, antiAliased: false))
                }

                if let next = current.sublayers?.first {
                    stack.append(StackValue(layer: current, layerIndex: currentLayerIndex, sublayerIndex: 0))

                    currentLayerIndex += 1
                    currentLayerOptional = next
                } else {
                    currentLayerOptional = nil
                }
            } else {
                if var previous = stack.popLast() {
                    previous.sublayerIndex += 1
                    
                    if let sublayers = previous.layer.sublayers, previous.sublayerIndex < sublayers.count {
                        stack.append(previous)
                        
                        currentLayerIndex += 1
                        currentLayerOptional = sublayers[previous.sublayerIndex]
                    } else {
                        if previous.layer.borderWidth > 0 && previous.layer.borderColor != nil {
                            renderContext.add(.bindVertexBuffer(index: previous.layerIndex))
                            renderContext.add(.border(antiAliased: true))
                        }
                    }
                } else {
                    break
                }
            }
        }
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

        if let backgroundColor = layer.backgroundColor, backgroundColor.alpha != 0 {
            renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
            renderContext.add(.background(antiAliased: true))
        }
        
        let drawableContents: TextureDrawable?

        if needsDisplay {
            switch layer.contents {
                case .some(let image as CGImage):
                    drawableContents = image

                case .some(let backingStore as CABackingStore):
                    backingStore.frontContext.flush()
                    drawableContents = backingStore

                default:
                    drawableContents = nil
            }

            if let drawableContents = drawableContents {
                if layer.texture == nil || layer.flags.contains(.needsNewTexture) {
                    layer.texture = try drawableContents.createTexture(renderStack: renderStack, graphicsQueue: renderContext.graphicsQueue, commandPool: commandPool)
                    layer.flags.remove(.needsNewTexture)
                }

                try drawableContents.drawIn(texture: layer.texture!, graphicsQueue: renderContext.graphicsQueue, commandPool: commandPool)
            }
        }

        if let layerTexture = layer.texture {
            renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
            renderContext.add(.contents(texture: layerTexture, layerIndex: currentLayerIndex, antiAliased: false))
        }

        try layer.sublayers?.forEach {
            index += 1
            try traverseLayerTree(for: $0, parentTransform: layerLocalTransform, index: &index, renderContext: renderContext)
        }

        if layer.borderWidth > 0, let borderColor = layer.borderColor, borderColor.alpha != 0 {
            renderContext.add(.bindVertexBuffer(index: currentLayerIndex))
            renderContext.add(.border(antiAliased: true))
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
    func sharedGraphicsPipelineDescriptor(subpassIndex: Int, descriptorSetLayouts: [DescriptorSetLayout], antiAliased: Bool) -> GraphicsPipelineDescriptor {
        let descriptor = GraphicsPipelineDescriptor()
    
        descriptor.descriptorSetLayouts = descriptorSetLayouts
        descriptor.viewportStateDefinition = .dynamic(viewportsCount: 1, scissorsCount: 1)

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

        if antiAliased {
            descriptor.sampleShadingEnabled = true
            descriptor.minSampleShading = 1.0
        } else {
            descriptor.sampleShadingEnabled = false
            descriptor.minSampleShading = 0.0
        }

        descriptor.rasterizationSamples = .four
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

        return descriptor
    }

    func createBackgroundPipeline(subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout], antiAliased: Bool = false) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try device.shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try device.shader(named: "BackgroundFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

        let descriptor = sharedGraphicsPipelineDescriptor(subpassIndex: subpassIndex, descriptorSetLayouts: descriptorSetLayouts, antiAliased: antiAliased)
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        return try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: self, subpassIndex: subpassIndex)
    }

    func createBorderPipeline(subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout], antiAliased: Bool = false) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try device.shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try device.shader(named: "BorderFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

        let descriptor = sharedGraphicsPipelineDescriptor(subpassIndex: subpassIndex, descriptorSetLayouts: descriptorSetLayouts, antiAliased: antiAliased)
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        return try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: self, subpassIndex: subpassIndex)
    }

    func createContentsPipeline(subpassIndex: Int = 0, descriptorSetLayouts: [DescriptorSetLayout], antiAliased: Bool = false) throws -> GraphicsPipeline {
        #if os(Linux)
            let bundle = Bundle.module
        #else
            let bundle = Bundle.main
        #endif

        let vertexShader = try device.shader(named: "LayerVertexShader", in: bundle, subdirectory: "ShaderBinaries")
        let fragmentShader = try device.shader(named: "ContentsFragmentShader", in: bundle, subdirectory: "ShaderBinaries")

        let descriptor = sharedGraphicsPipelineDescriptor(subpassIndex: subpassIndex, descriptorSetLayouts: descriptorSetLayouts, antiAliased: antiAliased)
        descriptor.vertexShader = vertexShader
        descriptor.fragmentShader = fragmentShader

        return try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: self, subpassIndex: subpassIndex)
    }
}

internal extension Device {
    func createMainRenderPass(pixelFormat: VkFormat) throws -> RenderPass {
        var colorAttachmentDescription = VkAttachmentDescription()
        colorAttachmentDescription.format = pixelFormat
        colorAttachmentDescription.samples = .four
        colorAttachmentDescription.loadOp = .clear
        colorAttachmentDescription.storeOp = .dontCare
        colorAttachmentDescription.stencilLoadOp = .dontCare
        colorAttachmentDescription.stencilStoreOp = .dontCare
        colorAttachmentDescription.initialLayout = .undefined
        colorAttachmentDescription.finalLayout = .colorAttachmentOptimal

        var resolveAttachmentDescription = VkAttachmentDescription()
        resolveAttachmentDescription.format = pixelFormat
        resolveAttachmentDescription.samples = .one
        resolveAttachmentDescription.loadOp = .dontCare
        resolveAttachmentDescription.storeOp = .store
        resolveAttachmentDescription.stencilLoadOp = .dontCare
        resolveAttachmentDescription.stencilStoreOp = .dontCare
        resolveAttachmentDescription.initialLayout = .undefined
        resolveAttachmentDescription.finalLayout = .presentSourceKhr

        let colorAttachment = Attachment(description: colorAttachmentDescription, imageLayout: .colorAttachmentOptimal)
        let resolveAttachment = Attachment(description: resolveAttachmentDescription, imageLayout: .colorAttachmentOptimal)
        let subpass1 = Subpass(bindPoint: .graphics, colorAttachments: [colorAttachment], resolveAttachments: [resolveAttachment])
        let dependency1 = Subpass.Dependency(destination: subpass1, sourceStage: .colorAttachmentOutput, destinationStage: .colorAttachmentOutput, destinationAccess: .colorAttachmentWrite)

        return try RenderPass(device: self, subpasses: [subpass1], dependencies: [dependency1])
    }
}

internal protocol TextureDrawable {
    var width: Int { get }
    var height: Int { get }
    var bytesPerRow: Int { get }
    var pixelData: UnsafeRawPointer { get }
}

extension TextureDrawable {
    func createTexture(renderStack: VolcanoRenderStack, graphicsQueue: Queue, commandPool: CommandPool, semaphores: [TimelineSemaphore] = []) throws -> Texture {
        let device = renderStack.device

        let textureDescriptor = TextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8UNorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.tiling = .optimal
        textureDescriptor.requiredMemoryProperties = .deviceLocal

        return try device.createTexture(with: textureDescriptor)
    }

    func drawIn(texture: Texture, graphicsQueue: Queue, commandPool: CommandPool, semaphores: [TimelineSemaphore] = []) throws {
        let device = texture.device

        let stagingBufferDescriptor = BufferDescriptor(stagingWithSize: VkDeviceSize(bytesPerRow * height), accessQueues: [graphicsQueue])

        let stagingBuffer = try device.memoryAllocator.create(with: stagingBufferDescriptor).result

        try stagingBuffer.memoryChunk.withMappedData { data, size in
            data.copyMemory(from: UnsafeRawPointer(pixelData), byteCount: Int(stagingBuffer.size))
        }

        try graphicsQueue.oneShot(in: commandPool, wait: true, semaphores: semaphores) {
            try $0.performPredefinedLayoutTransition(for: texture, newLayout: .transferDestinationOptimal)
            try $0.copyBuffer(from: stagingBuffer, to: texture, texelsPerRow: CUnsignedInt(width), height: CUnsignedInt(height))
            try $0.performPredefinedLayoutTransition(for: texture, newLayout: .shaderReadOnlyOptimal)
        }
    }
}

extension CGImage: TextureDrawable {
    var pixelData: UnsafeRawPointer {
        return UnsafeRawPointer(bitmap.baseAddress!)
    }
}

extension CABackingStore: TextureDrawable {
    var pixelData: UnsafeRawPointer {
        return UnsafeRawPointer(frontContext.data!)
    }
}

extension CGContext: TextureDrawable {
    var pixelData: UnsafeRawPointer {
        return UnsafeRawPointer(data!)
    }
}
