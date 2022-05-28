//
//  RenderTarget.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 28.08.2020.
//

import Foundation
import Volcano
import TinyFoundation
import CVulkan

@_spi(AppKid) public final class RenderTarget {
    let renderPass: RenderPass
    let colorAttachment: Texture
    let resolveAttachment: Texture?
    let framebuffer: Framebuffer
    let viewport: VkViewport
    let renderArea: VkRect2D
    let clearColor: VkClearValue?
    
    internal init(renderPass: RenderPass, colorAttachment: Texture, resolveAttachment: Texture? = nil, clearColor: VkClearValue? = nil) throws {
        let size = VkExtent2D(width: CUnsignedInt(colorAttachment.width), height: CUnsignedInt(colorAttachment.height))

        self.renderPass = renderPass
        self.colorAttachment = colorAttachment
        self.resolveAttachment = resolveAttachment

        let attachments = [colorAttachment, resolveAttachment]
            .compactMap { $0?.imageView }

        self.framebuffer = try Framebuffer(device: renderPass.device, size: size, renderPass: renderPass, attachments: attachments)

        self.viewport = VkViewport(x: 0.0, y: 0.0,
                                   width: Float(size.width), height: Float(size.height),
                                   minDepth: 0.0, maxDepth: 1.0)

        self.renderArea = VkRect2D(offset: .zero, extent: size)
        self.clearColor = clearColor
    }
}
