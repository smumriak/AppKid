//
//  VulkanRenderOperation.swift
//  AppKid
//
//  Created by Serhii Mumriak on 13.04.2021.
//

import Foundation
import CoreFoundation
import Volcano
import TinyFoundation

internal struct VulkanRenderContext {
    let renderStack: VulkanRenderStack
    let texturesStack: TextureStack

    func createRenderPass() throws -> RenderPass {
        abort()
    }
}

internal class VulkanRenderOperation {
    internal let context: VulkanRenderContext

    init(context: VulkanRenderContext) {
        self.context = context
    }

    func perform() {
    }
}

internal class SequenceRenderOperation: VulkanRenderOperation {
    fileprivate var suboperations: [VulkanRenderOperation] = []
    
    func add(suboperation: VulkanRenderOperation) {
        assert(suboperation !== self)

        suboperations.append(suboperation)
    }

    func add(suboperations: [VulkanRenderOperation]) {
        assert(!suboperations.contains(where: { $0 !== self }))

        self.suboperations.append(contentsOf: suboperations)
    }
}

internal class PushTextureOperation: VulkanRenderOperation {
    fileprivate let texture: Texture
    init(context: VulkanRenderContext, texture: Texture) {
        self.texture = texture

        super.init(context: context)
    }

    override func perform() {
        context.texturesStack.push(texture)
    }
}

internal class PopTextureOperation: VulkanRenderOperation {
    override func perform() {
        context.texturesStack.pop()
    }
}

internal class BindCommandBuffer: VulkanRenderOperation {
    fileprivate var commandBuffer: CommandBuffer

    init(context: VulkanRenderContext, commandBuffer: CommandBuffer) {
        self.commandBuffer = commandBuffer

        super.init(context: context)
    }
}
