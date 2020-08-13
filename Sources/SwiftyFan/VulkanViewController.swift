//
//  VulkanViewController.swift
//  AppKid
//
//  Created by Serhii Mumriak on 15.05.2020.
//

import Foundation
import AppKid
import Volcano
import TinyFoundation
import CVulkan

class VulkanViewController: ViewController {
    lazy var vulkanInstance: Instance = Instance()
    var physicalDevice: PhysicalDevice!
    var surface: Surface!
    var device: Device!
    var swapchain: Swapchain!
    var preesentationQueue: Queue!
    var graphicsQueue: Queue!
    var images: [Image]!
    var imageViews: [ImageView]!
    var vertexShader: Shader!
    var fragmentShader: Shader!
    var commandPool: CommandPool!
    var commandBuffer: CommandBuffer!
    var imageAvailableSemaphore: Semaphore!
    var renderFinishedSemaphore: Semaphore!

    deinit {
        imageAvailableSemaphore = nil
        renderFinishedSemaphore = nil
        commandBuffer = nil
        commandPool = nil
        fragmentShader = nil
        vertexShader = nil
        imageViews = nil
        images = nil
        graphicsQueue = nil
        preesentationQueue = nil
        swapchain = nil
        device = nil
        surface = nil
        physicalDevice = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        do {
            guard let window = self.view.window else { return }

            guard let physicalDevice = vulkanInstance.discreteGPUDevices else { return }

            self.physicalDevice = physicalDevice

            let windowSize = window.bounds.size
            let displayScale = window.nativeWindow.displayScale
            let size = VkExtent2D(width: UInt32(windowSize.width * displayScale), height: UInt32(windowSize.height * displayScale))
            surface = try physicalDevice.createXlibSurface(display: window.nativeWindow.display, window:  window.nativeWindow.windowID)

            device = try Device(surface: surface)

            preesentationQueue = try Queue(device: device, familyIndex: device.presentationQueueFamilyIndex, queueIndex: 0)
            graphicsQueue = try Queue(device: device, familyIndex: device.graphicsQueueFamilyIndex, queueIndex: 0)

            swapchain = try Swapchain(device: device, surface: surface, size: size)

            images = try swapchain.getImages()
            imageViews = try images.map { try ImageView(image: $0) }

            #if os(Linux)
            let bundle = Bundle.module
            #else
            let bundle = Bundle.main
            #endif

            vertexShader = try device.shader(named: "TriangleVertexShader", in: bundle)
            fragmentShader = try device.shader(named: "TriangleFragmentShader", in: bundle)

            commandPool = try CommandPool(device: device, queue: graphicsQueue)
            commandBuffer = try CommandBuffer(commandPool: commandPool)

            imageAvailableSemaphore = try Semaphore(device: device)
            renderFinishedSemaphore = try Semaphore(device: device)

            debugPrint("Vulcan loaded")

            let mainName = strdup("main")
            defer { free(mainName)}

            let fragmentShaderStageInfo = fragmentShader.createStageInfo(for: VK_SHADER_STAGE_FRAGMENT_BIT)
            let vertexShaderStageInfo = vertexShader.createStageInfo(for: VK_SHADER_STAGE_VERTEX_BIT)

            var vertexInputInfo = VkPipelineVertexInputStateCreateInfo()
            vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
            vertexInputInfo.vertexBindingDescriptionCount = 0
            vertexInputInfo.pVertexBindingDescriptions = nil
            vertexInputInfo.vertexAttributeDescriptionCount = 0
            vertexInputInfo.pVertexAttributeDescriptions = nil

            var inputAssembly = VkPipelineInputAssemblyStateCreateInfo()
            inputAssembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
            inputAssembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
            inputAssembly.primitiveRestartEnable = VkBool32(VK_FALSE)

            var viewport = SmartPointer<VkViewport>.allocate()
            viewport.pointee.x = 0.0
            viewport.pointee.y = 0.0
            viewport.pointee.width = Float(swapchain.size.width)
            viewport.pointee.height = Float(swapchain.size.height)
            viewport.pointee.minDepth = 0.0
            viewport.pointee.maxDepth = 1.0

            var scissor = SmartPointer<VkRect2D>.allocate()
            scissor.pointee.offset = VkOffset2D(x: 0, y: 0)
            scissor.pointee.extent = swapchain.size

            var viewportState = VkPipelineViewportStateCreateInfo(sType: VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
                                                                  pNext: nil,
                                                                  flags: VkPipelineViewportStateCreateFlags(),
                                                                  viewportCount: 1,
                                                                  pViewports: viewport.pointer,
                                                                  scissorCount: 1,
                                                                  pScissors: scissor.pointer)

            var rasterizer = VkPipelineRasterizationStateCreateInfo()
            rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
            rasterizer.depthClampEnable = VkBool32(VK_FALSE)
            rasterizer.rasterizerDiscardEnable = VkBool32(VK_FALSE)
            rasterizer.polygonMode = VK_POLYGON_MODE_FILL
            rasterizer.lineWidth = 1.0
            rasterizer.cullMode = VK_CULL_MODE_BACK_BIT.rawValue
            rasterizer.frontFace = VK_FRONT_FACE_CLOCKWISE
            rasterizer.depthBiasEnable = VkBool32(VK_FALSE)
            rasterizer.depthBiasConstantFactor = 0.0
            rasterizer.depthBiasClamp = 0.0
            rasterizer.depthBiasSlopeFactor = 0.0

            var multisampling = VkPipelineMultisampleStateCreateInfo()
            multisampling.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
            multisampling.sampleShadingEnable = VkBool32(VK_FALSE)
            multisampling.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT
            multisampling.minSampleShading = 1.0
            multisampling.pSampleMask = nil
            multisampling.alphaToCoverageEnable = VkBool32(VK_FALSE)
            multisampling.alphaToOneEnable = VkBool32(VK_FALSE)


            var colorBlendAttachment = SmartPointer<VkPipelineColorBlendAttachmentState>.allocate()
            colorBlendAttachment.pointee.colorWriteMask = VK_COLOR_COMPONENT_R_BIT.rawValue | VK_COLOR_COMPONENT_G_BIT.rawValue | VK_COLOR_COMPONENT_B_BIT.rawValue | VK_COLOR_COMPONENT_A_BIT.rawValue
            colorBlendAttachment.pointee.blendEnable = VkBool32(VK_FALSE)
            colorBlendAttachment.pointee.srcColorBlendFactor = VK_BLEND_FACTOR_ONE
            colorBlendAttachment.pointee.dstColorBlendFactor = VK_BLEND_FACTOR_ZERO
            colorBlendAttachment.pointee.colorBlendOp = VK_BLEND_OP_ADD
            colorBlendAttachment.pointee.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE
            colorBlendAttachment.pointee.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO
            colorBlendAttachment.pointee.alphaBlendOp = VK_BLEND_OP_ADD

            var colorBlending = VkPipelineColorBlendStateCreateInfo()
            colorBlending.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
            colorBlending.logicOpEnable = VkBool32(VK_FALSE)
            colorBlending.logicOp = VK_LOGIC_OP_COPY
            colorBlending.attachmentCount = 1;
            colorBlending.pAttachments = UnsafePointer(colorBlendAttachment.pointer)
            colorBlending.blendConstants = (0.0, 0.0, 0.0, 0.0)

            let dynamicStates: [VkDynamicState] = [
                VK_DYNAMIC_STATE_VIEWPORT,
                VK_DYNAMIC_STATE_LINE_WIDTH
            ];

            var dynamicState: VkPipelineDynamicStateCreateInfo = dynamicStates.withUnsafeBufferPointer {
                return VkPipelineDynamicStateCreateInfo(sType: VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO,
                                                                pNext: nil,
                                                                flags: VkPipelineDynamicStateCreateFlags(),
                                                                dynamicStateCount: CUnsignedInt($0.count),
                                                                pDynamicStates: $0.baseAddress!)
            }

            var pipelineLayoutInfo = VkPipelineLayoutCreateInfo()
            pipelineLayoutInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
            pipelineLayoutInfo.setLayoutCount = 0
            pipelineLayoutInfo.pSetLayouts = nil
            pipelineLayoutInfo.pushConstantRangeCount = 0
            pipelineLayoutInfo.pPushConstantRanges = nil

            let pipelineLayout = try device.create(with: pipelineLayoutInfo)

            var colorAttachment = VkAttachmentDescription()
            colorAttachment.format = swapchain.imageFormat
            colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT
            colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR
            colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE
            colorAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE
            colorAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE
            colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED
            colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR

            var colorAttachmentRef = VkAttachmentReference()
            colorAttachmentRef.attachment = 0
            colorAttachmentRef.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL

            var subpass = VkSubpassDescription()
            subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS
            subpass.colorAttachmentCount = 1
            withUnsafePointer(to: &colorAttachmentRef) {
                subpass.pColorAttachments = $0
            }

            var renderPassInfo = VkRenderPassCreateInfo()
            renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO
            renderPassInfo.attachmentCount = 1
            withUnsafePointer(to: &colorAttachment) {
                renderPassInfo.pAttachments = $0
            }
            renderPassInfo.subpassCount = 1
            withUnsafePointer(to: &subpass) {
                renderPassInfo.pSubpasses = $0
            }
            var dependency = VkSubpassDependency()
            dependency.srcSubpass = VK_SUBPASS_EXTERNAL
            dependency.dstSubpass = 0
            dependency.srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue
            dependency.srcAccessMask = 0
            dependency.dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue
            dependency.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT.rawValue
            let dependencies: [VkSubpassDependency] = [dependency]
            dependencies.withUnsafeBufferPointer { dependenciesPointer in
                renderPassInfo.dependencyCount = CUnsignedInt(dependenciesPointer.count)
                renderPassInfo.pDependencies = dependenciesPointer.baseAddress!
            }

            let renderPass = try device.create(with: renderPassInfo)

            let shaderStages = [vertexShaderStageInfo, fragmentShaderStageInfo]

            var pipelineInfo = VkGraphicsPipelineCreateInfo()
            pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
            pipelineInfo.stageCount = 2
            shaderStages.withUnsafeBufferPointer {
                pipelineInfo.pStages = $0.baseAddress!
            }

            withUnsafePointer(to: &vertexInputInfo) {
                pipelineInfo.pVertexInputState = $0
            }
            withUnsafePointer(to: &inputAssembly) {
                pipelineInfo.pInputAssemblyState = $0
            }
            withUnsafePointer(to: &viewportState) {
                pipelineInfo.pViewportState = $0
            }
            withUnsafePointer(to: &rasterizer) {
                pipelineInfo.pRasterizationState = $0
            }
            withUnsafePointer(to: &multisampling) {
                pipelineInfo.pMultisampleState = $0
            }
            withUnsafePointer(to: &colorBlending) {
                pipelineInfo.pColorBlendState = $0
            }
            pipelineInfo.layout = pipelineLayout.pointer
            pipelineInfo.renderPass = renderPass.pointer
            pipelineInfo.subpass = 0

            pipelineInfo.basePipelineHandle = nil
            pipelineInfo.basePipelineIndex = -1

            pipelineInfo.pDepthStencilState = nil
            pipelineInfo.pDynamicState = nil

            var pipelinePointer: UnsafeMutablePointer<VkPipeline_T>?
            try vulkanInvoke {
                vkCreateGraphicsPipelines(device.handle, nil, 1, &pipelineInfo, nil, &pipelinePointer)
            }
            let pipeline = SmartPointer(with: pipelinePointer!) { [unowned self] in
                vkDestroyPipeline(device.handle, $0, nil)
            }

            let framebuffers: [SmartPointer<VkFramebuffer_T>] = try imageViews.map { imageView in
                let attachments: [VkImageView?] = [imageView.handle]

                return try attachments.withUnsafeBufferPointer { attachmentsPointer in
                    var framebufferInfo = VkFramebufferCreateInfo()
                    framebufferInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
                    framebufferInfo.renderPass = renderPass.pointer
                    framebufferInfo.attachmentCount = 1
                    framebufferInfo.pAttachments = attachmentsPointer.baseAddress!
                    framebufferInfo.width = swapchain.size.width
                    framebufferInfo.height = swapchain.size.height
                    framebufferInfo.layers = 1

                    return try device.create(with: framebufferInfo)
                }
            }

            debugPrint("Stage 2")

            try commandBuffer.begin()

            var clearColor = VkClearValue(color: VkClearColorValue(float32: (0.0, 0.0, 0.0, 1.0)))
            try withUnsafePointer(to: &clearColor) { clearColorPointer in
                var renderPassBeginInfo = VkRenderPassBeginInfo()
                renderPassBeginInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
                renderPassBeginInfo.renderPass = renderPass.pointer
                renderPassBeginInfo.framebuffer = framebuffers[0].pointer
                renderPassBeginInfo.renderArea.offset = VkOffset2D(x: 0, y: 0)
                renderPassBeginInfo.renderArea.extent = swapchain.size
                renderPassBeginInfo.clearValueCount = 1
                renderPassBeginInfo.pClearValues = clearColorPointer

                try vulkanInvoke {
                    vkCmdBeginRenderPass(commandBuffer.handle, &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE)
                }
            }

            try commandBuffer.bind(pipeline: pipeline)

            try vulkanInvoke {
                vkCmdDraw(commandBuffer.handle, 3, 1, 0, 0)
            }

            try vulkanInvoke {
                vkCmdEndRenderPass(commandBuffer.handle)
            }

            try commandBuffer.end()

            debugPrint("Stage 3")

            var imageIndex: CUnsignedInt = 0

            try vulkanInvoke {
                vkAcquireNextImageKHR(device.handle, swapchain.handle, UInt64.max, imageAvailableSemaphore.handle, nil, &imageIndex)
            }

            let waitSemaphores: [VkSemaphore?] = [imageAvailableSemaphore.handle]
            let signalSemaphores: [VkSemaphore?] = [renderFinishedSemaphore.handle]
            let waitStages: [VkPipelineStageFlags] = [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue]

            let commandBuffers: [VkCommandBuffer?] = [commandBuffer.handle]
            try waitSemaphores.withUnsafeBufferPointer { waitSemaphoresPointer in 
                try signalSemaphores.withUnsafeBufferPointer { signalSemaphoresPointer in
                    try waitStages.withUnsafeBufferPointer { waitStagesPointer in 
                        try commandBuffers.withUnsafeBufferPointer { commandBufferPointer in
                            var submitInfo = VkSubmitInfo()
                            submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO

                            submitInfo.waitSemaphoreCount = CUnsignedInt(waitSemaphoresPointer.count)
                            submitInfo.pWaitSemaphores = waitSemaphoresPointer.baseAddress!

                            submitInfo.signalSemaphoreCount = CUnsignedInt(signalSemaphoresPointer.count)
                            submitInfo.pSignalSemaphores = signalSemaphoresPointer.baseAddress!

                            submitInfo.pWaitDstStageMask = waitStagesPointer.baseAddress!
                            
                            submitInfo.commandBufferCount = CUnsignedInt(commandBufferPointer.count)
                            submitInfo.pCommandBuffers = commandBufferPointer.baseAddress!
                            
                            try vulkanInvoke {
                                vkQueueSubmit(graphicsQueue.handle, 1, &submitInfo, nil)
                            }
                        }
                    }
                }
            }

            debugPrint("Stage 4")

            var presentInfo = VkPresentInfoKHR()
            presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
            try signalSemaphores.withUnsafeBufferPointer { signalSemaphoresPointer in
                presentInfo.waitSemaphoreCount = CUnsignedInt(signalSemaphoresPointer.count)
                presentInfo.pWaitSemaphores = signalSemaphoresPointer.baseAddress
            }

            let swapchains: [VkSwapchainKHR?] = [swapchain.handle]
            swapchains.withUnsafeBufferPointer { swapchainsPointer in
                presentInfo.swapchainCount = CUnsignedInt(swapchainsPointer.count)
                presentInfo.pSwapchains = swapchainsPointer.baseAddress!
            }
            let imageIndices: [CUnsignedInt] = [imageIndex]
            imageIndices.withUnsafeBufferPointer { imageIndicesPointer in
                presentInfo.pImageIndices = imageIndicesPointer.baseAddress!
            }
            presentInfo.pResults = nil
            vkQueuePresentKHR(preesentationQueue.handle, &presentInfo)

            
        } catch {
            fatalError("Failed to load vulkan with error: \(error)")
        }
    }
}
