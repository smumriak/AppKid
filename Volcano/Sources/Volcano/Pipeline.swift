//
//  Pipeline.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2020.
//

import TinyFoundation
import CVulkan

public class Pipeline: VulkanDeviceEntity<SmartPointer<VkPipeline_T>> {
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

    public init(device: Device, descriptor pipelineDescriptor: GraphicsPipelineDescriptor, renderPass: RenderPass, subpassIndex: Int) throws {
        #if EXPERIMENTAL_VOLCANO_DSL

            let layout: SmartPointer<VkPipelineLayout_T> = try VkBuilder<VkPipelineLayoutCreateInfo> {
                (\.setLayoutCount, \.pSetLayouts) <- pipelineDescriptor.descriptorSetLayouts.optionalPointers()
                (\.pushConstantRangeCount, \.pPushConstantRanges) <- pipelineDescriptor.pushConstants
            }
            .createEntity(using: device)

            @VkBuilder<VkGraphicsPipelineCreateInfo>
            var builder: VkBuilder<VkGraphicsPipelineCreateInfo> {
                \.pViewportState <- pipelineDescriptor.viewportState
                \.pVertexInputState <- pipelineDescriptor.vertexInputState
                \.pInputAssemblyState <- pipelineDescriptor.inputAssemblyState
                \.pRasterizationState <- pipelineDescriptor.rasterizationState
                \.pMultisampleState <- pipelineDescriptor.multisampleState
                \.pColorBlendState <- pipelineDescriptor.colorBlendState
                \.pDynamicState <- pipelineDescriptor.dynamicState

                (\.stageCount, \.pStages) <- [
                    pipelineDescriptor.vertexShader.map {
                        $0.createStageInfo(for: .vertex)
                    },
                    pipelineDescriptor.fragmentShader.map {
                        $0.createStageInfo(for: .fragment)
                    },
                ].compactMap { $0 }
                
                \.layout <- layout
                \.renderPass <- renderPass.handle
                \.subpass <- CUnsignedInt(subpassIndex)

                \.basePipelineHandle <- nil
                \.basePipelineIndex <- -1
            }

            let handlePointer: SmartPointer<VkPipeline_T> = try builder.withUnsafeResultPointer { info in
                var handle: UnsafeMutablePointer<VkPipeline_T>?
                try vulkanInvoke {
                    vkCreateGraphicsPipelines(device.handle, nil, 1, info, nil, &handle)
                }

                return SmartPointer(with: handle!) { [device] in
                    vkDestroyPipeline(device.handle, $0, nil)
                }
            }

        #else

            let layout: SmartPointer<VkPipelineLayout_T> = try pipelineDescriptor.descriptorSetLayouts.optionalPointers()
                .withUnsafeBufferPointer { descriptorSetLayouts in
                    return try pipelineDescriptor.pushConstants.withUnsafeBufferPointer { pushConstants in
                        var info = VkPipelineLayoutCreateInfo()
                        info.sType = .pipelineLayoutCreateInfo
                        info.setLayoutCount = CUnsignedInt(descriptorSetLayouts.count)
                        info.pSetLayouts = descriptorSetLayouts.baseAddress!

                        info.pushConstantRangeCount = 0
                        info.pPushConstantRanges = pushConstants.baseAddress!

                        return try device.create(with: &info)
                    }
                }

            let handlePointer: SmartPointer<VkPipeline_T> =
                try pipelineDescriptor.withVertexStateCreateInfoPointer { viewportStateInfo in
                    return try pipelineDescriptor.withVertexInputCreateInfoPointer { vertexInputInfo in
                        return try pipelineDescriptor.withInputAssemblyCreateInfoPointer { inputAssemblyInfo in
                            return try pipelineDescriptor.withRasterizationStateCreateInfoPointer { rasterizationStateInfo in
                                return try pipelineDescriptor.withMultisampleStateCreateInfoPointer { multisampleStateInfo in
                                    return try pipelineDescriptor.withColorBlendStateCreateInfo { colorBlendStateCreateInfo in
                                        return try pipelineDescriptor.withDynamicStateCreateInfo { dynamicStateInfo in
                                            return try pipelineDescriptor.withStageCreateInfosBufferPointer { stageInfos in
                                                var info = VkGraphicsPipelineCreateInfo()
                                                info.sType = .graphicsPipelineCreateInfo

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
                                                info.renderPass = renderPass.handle
                                                info.subpass = CUnsignedInt(subpassIndex)

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

        self.renderPass = renderPass
        self.subpassIndex = subpassIndex
        self.descriptorSetLayouts = pipelineDescriptor.descriptorSetLayouts

        try super.init(device: device, handlePointer: handlePointer, layout: layout)
    }
}
