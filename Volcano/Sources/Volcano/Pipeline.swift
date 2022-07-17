//
//  Pipeline.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2020.
//

import TinyFoundation
import CVulkan

public class Pipeline: DeviceEntity<SmartPointer<VkPipeline_T>> {
    public internal(set) var layout: SmartPointer<VkPipelineLayout_T>

    public init(device: Device, handlePointer: SmartPointer<VkPipeline_T>, layout: SmartPointer<VkPipelineLayout_T>) throws {
        self.layout = layout

        try super.init(device: device, handlePointer: handlePointer)
    }
}

public final class GraphicsPipeline: Pipeline {
    public internal(set) var renderPass: RenderPass
    public internal(set) var subpassIndex: Int
    public internal(set) var descriptorSetLayouts: [DescriptorSetLayout]

    fileprivate init(device: Device, handlePointer: SmartPointer<VkPipeline_T>, layout: SmartPointer<VkPipelineLayout_T>, renderPass: RenderPass, subpassIndex: Int, descriptorSetLayouts: [DescriptorSetLayout]) throws {
        self.renderPass = renderPass
        self.subpassIndex = subpassIndex
        self.descriptorSetLayouts = descriptorSetLayouts

        try super.init(device: device, handlePointer: handlePointer, layout: layout)
    }

    public convenience init(device: Device, descriptor: GraphicsPipelineDescriptor, cache: VkPipelineCache? = nil) throws {
        #if VOLCANO_EXPERIMENTAL_DSL

            let layout = try device.buildEntity(VkPipelineLayoutCreateInfo.self) {
                (\.setLayoutCount, \.pSetLayouts) <- descriptor.descriptorSetLayouts.optionalHandles()
                (\.pushConstantRangeCount, \.pPushConstantRanges) <- descriptor.pushConstants
            }

            let handlePointer = try device.buildEntity(cache: nil, descriptor.createBuilder(layout))
        #else

            let layout: SmartPointer<VkPipelineLayout_T> = try descriptor.descriptorSetLayouts.optionalHandles()
                .withUnsafeBufferPointer { descriptorSetLayouts in
                    return try descriptor.pushConstants.withUnsafeBufferPointer { pushConstants in
                        var info = VkPipelineLayoutCreateInfo.new()
                        info.setLayoutCount = CUnsignedInt(descriptorSetLayouts.count)
                        info.pSetLayouts = descriptorSetLayouts.baseAddress!

                        info.pushConstantRangeCount = 0
                        info.pPushConstantRanges = pushConstants.baseAddress!

                        return try device.create(with: &info)
                    }
                }

            let handlePointer: SmartPointer<VkPipeline_T> =
                try descriptor.withVertexStateCreateInfoPointer { viewportStateInfo in
                    return try descriptor.withVertexInputCreateInfoPointer { vertexInputInfo in
                        return try descriptor.withInputAssemblyCreateInfoPointer { inputAssemblyInfo in
                            return try descriptor.withRasterizationStateCreateInfoPointer { rasterizationStateInfo in
                                return try descriptor.withMultisampleStateCreateInfoPointer { multisampleStateInfo in
                                    return try descriptor.withColorBlendStateCreateInfo { colorBlendStateCreateInfo in
                                        return try descriptor.withDynamicStateCreateInfo { dynamicStateInfo in
                                            return try descriptor.withStageCreateInfosBufferPointer { stageInfos in
                                                var info = VkGraphicsPipelineCreateInfo.new()

                                                info.pViewportState = viewportStateInfo
                                                info.pVertexInputState = vertexInputInfo
                                                info.pInputAssemblyState = inputAssemblyInfo
                                                info.pRasterizationState = rasterizationStateInfo
                                                info.pMultisampleState = multisampleStateInfo
                                                info.pColorBlendState = colorBlendStateCreateInfo
                                                info.pDynamicState = dynamicStateInfo

                                                info.stageCount = CUnsignedInt(stageInfos.count)
                                                info.pStages = stageInfos.baseAddress!

                                                info.layout = layout.pointer
                                                info.renderPass = descriptor.renderPass.handle
                                                info.subpass = CUnsignedInt(descriptor.subpassIndex)

                                                info.basePipelineHandle = nil
                                                info.basePipelineIndex = -1

                                                var handle: UnsafeMutablePointer<VkPipeline_T>?
                                                try vulkanInvoke {
                                                    vkCreateGraphicsPipelines(device.handle, nil, 1, &info, nil, &handle)
                                                }

                                                return SmartPointer(with: handle!) { [device] in
                                                    vkDestroyPipeline(device.handle, $0, nil)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
        #endif

        try self.init(device: device, handlePointer: handlePointer, layout: layout, renderPass: descriptor.renderPass, subpassIndex: descriptor.subpassIndex, descriptorSetLayouts: descriptor.descriptorSetLayouts)
    }
}

public extension Device {
    func createPipelines(from descriptors: [GraphicsPipelineDescriptor], cache: VkPipelineCache? = nil) throws -> [GraphicsPipeline] {
        let layouts = try descriptors.map { descriptor in
            try buildEntity(VkPipelineLayoutCreateInfo.self) {
                (\.setLayoutCount, \.pSetLayouts) <- descriptor.descriptorSetLayouts.optionalHandles()
                (\.pushConstantRangeCount, \.pPushConstantRanges) <- descriptor.pushConstants
            }
        }

        let handlePointers = try buildEntities(VkGraphicsPipelineCreateInfo.self, cache: cache) {
            for i in 0..<descriptors.count {
                descriptors[i].createBuilder(layouts[i])
            }
        }

        return try handlePointers.enumerated().map {
            let descriptor = descriptors[$0]
            let layout = layouts[$0]
            return try GraphicsPipeline(device: self, handlePointer: $1, layout: layout, renderPass: descriptor.renderPass, subpassIndex: descriptor.subpassIndex, descriptorSetLayouts: descriptor.descriptorSetLayouts)
        }
    }
}
