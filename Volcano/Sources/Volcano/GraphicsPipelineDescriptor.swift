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

    // MARK: Pipelie Layout

    public var descriptorSetLayouts: [DescriptorSetLayout] = []
    public var pushConstants: [VkPushConstantRange] = []

    // MARK: Viewport State

    internal var _viewportState: ViewportState!
    public var viewportState: ViewportState {
        get { _viewportState }
        set { _viewportState = newValue }
    }

    public var depthAttachmentPixelFormat: VkFormat = .undefined
    public var stencilAttachmentPixelFormat: VkFormat = .undefined

    // MARK: Vertex Input

    public var vertexInputBindingDescriptions: [VkVertexInputBindingDescription] = []
    public var inputAttributeDescrioptions: [VkVertexInputAttributeDescription] = []

    // MARK: Input Aseembly

    public var inputPrimitiveTopology: VkPrimitiveTopology = .pointList
    public var primitiveRestartEnabled: Bool = false
    
    // MARK: Rasterizer

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

    // MARK: Multisampling

    public var rasterizationSamples: VkSampleCountFlagBits = .one
    public var sampleShadingEnabled: Bool = false
    public var minSampleShading: Float = 1.0
    public var sampleMasks: [VkSampleMask] = []
    public var alphaToCoverageEnabled: Bool = false
    public var alphaToOneEnabled: Bool = false

    // MARK: Color Blend

    public var logicOperationEnabled: Bool = false
    public var logicOperation: VkLogicOp = .clear
    public var colorBlendAttachments: [VkPipelineColorBlendAttachmentState] = []
    public var blendConstants: (Float, Float, Float, Float) = (0.0, 0.0, 0.0, 0.0)

    // MARK: Dynamic state

    public var dynamicStates: [VkDynamicState] = []
    
    public init() {}
}

internal extension GraphicsPipelineDescriptor {
    @inlinable @inline(__always)
    func withVertexStateCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineViewportStateCreateInfo>) throws -> (T)) rethrows -> T {
        var info = VkPipelineViewportStateCreateInfo()
        info.sType = .pipelineViewportStateCreateInfo

        switch viewportState {
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

    @inlinable @inline(__always)
    func withVertexInputCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineVertexInputStateCreateInfo>) throws -> (T)) rethrows -> T {
        return try vertexInputBindingDescriptions.withUnsafeBufferPointer { vertexInputBindingDescriptions in
            return try inputAttributeDescrioptions.withUnsafeBufferPointer { inputAttributeDescrioptions in
                var info = VkPipelineVertexInputStateCreateInfo()
                info.sType = .pipelineVertexInputStateCreateInfo

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

    @inlinable @inline(__always)
    func withInputAssemblyCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineInputAssemblyStateCreateInfo>) throws -> (T)) rethrows -> T {
        var info = VkPipelineInputAssemblyStateCreateInfo()
        info.sType = .pipelineInputAssemblyStateCreateInfo
        info.topology = inputPrimitiveTopology
        info.primitiveRestartEnabled = primitiveRestartEnabled

        return try withUnsafePointer(to: &info) { info in
            return try body(info)
        }
    }

    @inlinable @inline(__always)
    func withRasterizationStateCreateInfoPointer<T>(_ body: (UnsafePointer<VkPipelineRasterizationStateCreateInfo>) throws -> (T)) rethrows -> T {
        var info = VkPipelineRasterizationStateCreateInfo()
        info.sType = .pipelineRasterizationStateCreateInfo
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

    @inlinable @inline(__always)
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

    @inlinable @inline(__always)
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

    @inlinable @inline(__always)
    func withDynamicStateCreateInfo<T>(_ body: (UnsafePointer<VkPipelineDynamicStateCreateInfo>) throws -> (T)) rethrows -> T {
        var dynamicStates = self.dynamicStates

        dynamicStates += viewportState.dynamicStates

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

    @inlinable @inline(__always)
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

internal protocol PipelineStatePiece {
    var dynamicStates: [VkDynamicState] { get }
}

public enum ViewportState: PipelineStatePiece {
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
