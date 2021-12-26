//
//  GraphicsPipelineDescriptor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.01.2021.
//

import TinyFoundation
import CVulkan

public class GraphicsPipelineDescriptor {
    public var vertexShader: Shader?
    public var fragmentShader: Shader?

    // MARK: - Pipelie Layout

    public var descriptorSetLayouts: [DescriptorSetLayout] = []
    public var pushConstants: [VkPushConstantRange] = []

    // MARK: - Viewport State

    internal var _viewportStateDefinition: ViewportStateDefinition!
    public var viewportStateDefinition: ViewportStateDefinition {
        get { _viewportStateDefinition }
        set { _viewportStateDefinition = newValue }
    }

    public var depthAttachmentPixelFormat: VkFormat = .undefined
    public var stencilAttachmentPixelFormat: VkFormat = .undefined

    // MARK: - Vertex Input

    public var vertexInputBindingDescriptions: [VkVertexInputBindingDescription] = []
    public var inputAttributeDescrioptions: [VkVertexInputAttributeDescription] = []

    // MARK: - Input Aseembly

    public var inputPrimitiveTopology: VkPrimitiveTopology = .pointList
    public var primitiveRestartEnabled: Bool = false
    
    // MARK: - Rasterizer

    public var depthClampEnabled: Bool = false
    public var discardEnabled: Bool = false
    public var polygonMode: VkPolygonMode = .fill
    public var cullModeFlags: VkCullModeFlagBits = []
    public var frontFace: VkFrontFace = .counterClockwise
    public var depthBiasEnabled: Bool = false
    public var depthBiasConstantFactor: Float = 0.0
    public var depthBiasClamp: Float = 0.0
    public var depthBiasSlopeFactor: Float = 0.0
    public var lineWidth: Float = 0.0

    // MARK: - Multisampling

    public var rasterizationSamples: VkSampleCountFlagBits = .one
    public var sampleShadingEnabled: Bool = false
    public var minSampleShading: Float = 1.0
    public var sampleMasks: [VkSampleMask] = []
    public var alphaToCoverageEnabled: Bool = false
    public var alphaToOneEnabled: Bool = false

    // MARK: - Color Blend

    public var logicOperationEnabled: Bool = false
    public var logicOperation: VkLogicOp = .clear
    public var colorBlendAttachments: [VkPipelineColorBlendAttachmentState] = []
    public var blendConstants: (Float, Float, Float, Float) = (0.0, 0.0, 0.0, 0.0)

    // MARK: - Dynamic state

    public var dynamicStates: [VkDynamicState] = []
    
    public init() {}
}

internal extension GraphicsPipelineDescriptor {
    @_transparent
    func withVertexStateCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineViewportStateCreateInfo>) throws -> (T)) rethrows -> T {
        var info = VkPipelineViewportStateCreateInfo()
        info.sType = .pipelineViewportStateCreateInfo

        switch viewportStateDefinition {
            case .static(let viewports, let scissors):
                return try viewports.withUnsafeBufferPointer { viewports in
                    return try scissors.withUnsafeBufferPointer { scissors in
                        info.viewportCount = CUnsignedInt(viewports.count)
                        info.pViewports = viewports.baseAddress!
                        info.scissorCount = CUnsignedInt(scissors.count)
                        info.pScissors = scissors.baseAddress!

                        return try withUnsafePointer(to: &info) { info in
                            return try body(info)
                        }
                    }
                }
            
            case .dynamic(let viewportsCount, let scissorsCount):
                info.viewportCount = CUnsignedInt(viewportsCount)
                info.pViewports = nil
                info.scissorCount = CUnsignedInt(scissorsCount)
                info.pScissors = nil

                return try withUnsafePointer(to: &info) { info in
                    return try body(info)
                }
        }
    }

    @_transparent
    func withVertexInputCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineVertexInputStateCreateInfo>) throws -> (T)) rethrows -> T {
        return try vertexInputBindingDescriptions.withUnsafeBufferPointer { vertexInputBindingDescriptions in
            return try inputAttributeDescrioptions.withUnsafeBufferPointer { inputAttributeDescrioptions in
                var info = VkPipelineVertexInputStateCreateInfo.new()

                info.vertexBindingDescriptionCount = CUnsignedInt(vertexInputBindingDescriptions.count)
                info.pVertexBindingDescriptions = vertexInputBindingDescriptions.baseAddress!

                info.vertexAttributeDescriptionCount = CUnsignedInt(inputAttributeDescrioptions.count)
                info.pVertexAttributeDescriptions = inputAttributeDescrioptions.baseAddress!

                return try withUnsafePointer(to: &info) { info in
                    return try body(info)
                }
            }
        }
    }

    @_transparent
    func withInputAssemblyCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineInputAssemblyStateCreateInfo>) throws -> (T)) rethrows -> T {
        var info = VkPipelineInputAssemblyStateCreateInfo.new()
        info.topology = inputPrimitiveTopology
        info.primitiveRestartEnabled = primitiveRestartEnabled

        return try withUnsafePointer(to: &info) { info in
            return try body(info)
        }
    }

    @_transparent
    func withRasterizationStateCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineRasterizationStateCreateInfo>) throws -> (T)) rethrows -> T {
        var info = VkPipelineRasterizationStateCreateInfo.new()
        info.depthClampEnabled = false
        info.discardEnabled = false
        info.polygonMode = .fill
        info.cullModeFlags = []
        info.frontFace = .counterClockwise
        info.depthBiasEnabled = false
        info.depthBiasConstantFactor = 0.0
        info.depthBiasClamp = 0.0
        info.depthBiasSlopeFactor = 0.0
        info.lineWidth = 1.0

        return try withUnsafePointer(to: &info) { info in
            return try body(info)
        }
    }
    
    @_transparent
    func withMultisampleStateCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineMultisampleStateCreateInfo>) throws -> (T)) rethrows -> T {
        return try sampleMasks.withUnsafeBufferPointer { sampleMasks in
            var info = VkPipelineMultisampleStateCreateInfo()
            info.sType = .pipelineMultisampleStateCreateInfo
            info.sampleShadingEnabled = sampleShadingEnabled
            info.rasterizationSamples = rasterizationSamples
            info.minSampleShading = minSampleShading
            info.pSampleMask = sampleMasks.isEmpty ? nil : sampleMasks.baseAddress!
            info.alphaToCoverageEnabled = alphaToCoverageEnabled
            info.alphaToOneEnabled = alphaToOneEnabled

            return try withUnsafePointer(to: &info) { info in
                return try body(info)
            }
        }
    }

    @_transparent
    func withColorBlendStateCreateInfo<T>(_ body: (UnsafePointer<VkPipelineColorBlendStateCreateInfo>) throws -> (T)) rethrows -> T {
        return try colorBlendAttachments.withUnsafeBufferPointer { colorBlendAttachments in
            var info = VkPipelineColorBlendStateCreateInfo()
            info.sType = .pipelineColorBlendStateCreateInfo
            info.logicOperationEnabled = logicOperationEnabled
            info.logicOperation = logicOperation
            info.attachmentCount = CUnsignedInt(colorBlendAttachments.count)
            info.pAttachments = colorBlendAttachments.baseAddress!
            info.blendConstants = blendConstants

            return try withUnsafePointer(to: &info) { info in
                return try body(info)
            }
        }
    }

    @_transparent
    func withDynamicStateCreateInfo<T>(_ body: (UnsafePointer<VkPipelineDynamicStateCreateInfo>) throws -> (T)) rethrows -> T {
        var dynamicStates = self.dynamicStates

        dynamicStates += viewportStateDefinition.dynamicStates

        let filteredDynamicStates = Array(Set(dynamicStates))
        
        return try filteredDynamicStates.withUnsafeBufferPointer { dynamicStates in
            var info = VkPipelineDynamicStateCreateInfo()
            info.sType = .pipelineDynamicStateCreateInfo
            info.dynamicStateCount = CUnsignedInt(dynamicStates.count)
            info.pDynamicStates = dynamicStates.baseAddress!

            return try withUnsafePointer(to: &info) { info in
                return try body(info)
            }
        }
    }

    @_transparent
    func withStageCreateInfosBufferPointer<T>(_ body: (UnsafeBufferPointer<VkPipelineShaderStageCreateInfo>) throws -> (T)) rethrows -> T {
        var infos: [VkPipelineShaderStageCreateInfo] = []
                                
        vertexShader.map { vertexShader in
            infos.append(vertexShader.createStageInfo(for: .vertex))
        }

        fragmentShader.map { fragmentShader in
            infos.append(fragmentShader.createStageInfo(for: .fragment))
        }

        return try infos.withUnsafeBufferPointer { infos in
            return try body(infos)
        }
    }
}

// #if EXPERIMENTAL_VOLCANO_DSL
    extension GraphicsPipelineDescriptor {
        @_transparent
        @VkBuilder<VkPipelineViewportStateCreateInfo>
        var viewportState: VkBuilder<VkPipelineViewportStateCreateInfo> {
            switch viewportStateDefinition {
                case .static(let viewports, let scissors):
                    (\.viewportCount, \.pViewports) <- viewports
                    (\.scissorCount, \.pScissors) <- scissors

                case .dynamic(let viewportsCount, let scissorsCount):
                    (\.viewportCount, \.pViewports) <- viewportsCount
                    (\.scissorCount, \.pScissors) <- scissorsCount
            }
        }

        @_transparent
        @VkBuilder<VkPipelineVertexInputStateCreateInfo>
        var vertexInputState: VkBuilder<VkPipelineVertexInputStateCreateInfo> {
            (\.vertexBindingDescriptionCount, \.pVertexBindingDescriptions) <- vertexInputBindingDescriptions
            (\.vertexAttributeDescriptionCount, \.pVertexAttributeDescriptions) <- inputAttributeDescrioptions
        }

        @_transparent
        @VkBuilder<VkPipelineInputAssemblyStateCreateInfo>
        var inputAssemblyState: VkBuilder<VkPipelineInputAssemblyStateCreateInfo> {
            \.topology <- inputPrimitiveTopology
            \.primitiveRestartEnabled <- primitiveRestartEnabled
        }

        @_transparent
        @VkBuilder<VkPipelineRasterizationStateCreateInfo>
        var rasterizationState: VkBuilder<VkPipelineRasterizationStateCreateInfo> {
            \.depthClampEnabled <- false
            \.discardEnabled <- false
            \.polygonMode <- .fill
            \.cullModeFlags <- []
            \.frontFace <- .counterClockwise
            \.depthBiasEnabled <- false
            \.depthBiasConstantFactor <- 0.0
            \.depthBiasClamp <- 0.0
            \.depthBiasSlopeFactor <- 0.0
            \.lineWidth <- 1.0
        }

        @_transparent
        @VkBuilder<VkPipelineMultisampleStateCreateInfo>
        var multisampleState: VkBuilder<VkPipelineMultisampleStateCreateInfo> {
            \.sampleShadingEnabled <- sampleShadingEnabled
            \.rasterizationSamples <- rasterizationSamples
            \.minSampleShading <- minSampleShading
            if sampleMasks.isEmpty == false {
                \.pSampleMask <- sampleMasks
            }
            \.alphaToCoverageEnabled <- alphaToCoverageEnabled
            \.alphaToOneEnabled <- alphaToOneEnabled
        }

        @_transparent
        @VkBuilder<VkPipelineColorBlendStateCreateInfo>
        var colorBlendState: VkBuilder<VkPipelineColorBlendStateCreateInfo> {
            \.logicOperationEnabled <- logicOperationEnabled
            \.logicOperation <- logicOperation
            (\.attachmentCount, \.pAttachments) <- colorBlendAttachments
            \.blendConstants <- blendConstants
        }

        @_transparent
        @VkBuilder<VkPipelineDynamicStateCreateInfo>
        var dynamicState: VkBuilder<VkPipelineDynamicStateCreateInfo> {
            (\.dynamicStateCount, \.pDynamicStates) <- Array(Set(dynamicStates + viewportStateDefinition.dynamicStates))
        }
    }
// #endif
internal protocol PipelineStatePiece {
    var dynamicStates: [VkDynamicState] { get }
}

public enum ViewportStateDefinition: PipelineStatePiece {
    case `static`(viewports: [VkViewport], scissors: [VkRect2D])
    case dynamic(viewportsCount: Int, scissorsCount: Int)

    public var dynamicStates: [VkDynamicState] {
        switch self {
            case .static(_, _): return []
            case .dynamic(_, _): return [.viewport, .scissor]
        }
    }
}

public extension VkPipelineRasterizationStateCreateInfo {
    var depthClampEnabled: Bool {
        get { depthClampEnable == VK_TRUE }
        set { depthClampEnable = newValue.vkBool }
    }

    var discardEnabled: Bool {
        get { rasterizerDiscardEnable == VK_TRUE }
        set { rasterizerDiscardEnable = newValue.vkBool }
    }

    var depthBiasEnabled: Bool {
        get { depthBiasEnable == VK_TRUE }
        set { depthBiasEnable = newValue.vkBool }
    }

    var cullModeFlags: VkCullModeFlagBits {
        get { VkCullModeFlagBits(rawValue: cullMode) }
        set { cullMode = newValue.rawValue }
    }
}

public extension VkPipelineInputAssemblyStateCreateInfo {
    var primitiveRestartEnabled: Bool {
        get { primitiveRestartEnable == VK_TRUE }
        set { primitiveRestartEnable = newValue.vkBool }
    }
}

public extension VkPipelineMultisampleStateCreateInfo {
    var sampleShadingEnabled: Bool {
        get { sampleShadingEnable == VK_TRUE }
        set { sampleShadingEnable = newValue.vkBool }
    }

    var alphaToCoverageEnabled: Bool {
        get { alphaToCoverageEnable == VK_TRUE }
        set { alphaToCoverageEnable = newValue.vkBool }
    }

    var alphaToOneEnabled: Bool {
        get { alphaToOneEnable == VK_TRUE }
        set { alphaToOneEnable = newValue.vkBool }
    }
}

public extension VkPipelineColorBlendAttachmentState {
    var blendEnabled: Bool {
        get { blendEnable == VK_TRUE }
        set { blendEnable = newValue.vkBool }
    }

    var colorComponentMask: VkColorComponentFlagBits {
        get { VkColorComponentFlagBits(rawValue: colorWriteMask) }
        set { colorWriteMask = newValue.rawValue }
    }
}

public extension VkPipelineColorBlendStateCreateInfo {
    var logicOperationEnabled: Bool {
        get { logicOpEnable == VK_TRUE }
        set { logicOpEnable = newValue.vkBool }
    }

    var logicOperation: VkLogicOp {
        get { logicOp }
        set { logicOp = newValue }
    }
}

public extension VkDescriptorSetLayoutBinding {
    var stages: VkShaderStageFlagBits {
        get { VkShaderStageFlagBits(rawValue: stageFlags) }
        set { stageFlags = newValue.rawValue }
    }
}
