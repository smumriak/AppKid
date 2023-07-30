//
//  RenderPass.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2020.
//

import TinyFoundation

public class RenderPass: DeviceEntity<VkRenderPass_T> {
    public init(device: Device, subpasses: [Subpass], dependencies: [Subpass.Dependency]) throws {
        let builder = RenderPassBuilder()
       
        subpasses.forEach { builder.add(subpass: $0) }
        dependencies.forEach { builder.add(dependency: $0) }

        let handle = try builder.buid(device: device)

        try super.init(device: device, handle: handle)
    }
}

internal final class RenderPassBuilder {
    fileprivate(set) var subpasses: [Subpass] = []
    fileprivate(set) var dependencies: [VkSubpassDependency] = []
    internal var attachments: [Attachment] = []

    func buid(device: Device) throws -> SharedPointer<VkRenderPass_T> {
        try subpasses.withUnsafeSubpassDescriptionBufferPointer(renderPassBuilder: self) { subpasses in
            try device.buildEntity(VkRenderPassCreateInfo.self) {
                (\.attachmentCount, \.pAttachments) <- attachments.map { $0.description }
                (\.subpassCount, \.pSubpasses) <- subpasses
                (\.dependencyCount, \.pDependencies) <- dependencies
            }
        }
    }

    func add(subpass: Subpass) {
        if subpasses.contains(subpass) {
            return
        }

        subpasses.append(subpass)

        subpass.inputAttachments.map {
            attachments.append(contentsOf: $0)
        }

        subpass.colorAttachments.map {
            attachments.append(contentsOf: $0)
        }

        subpass.resolveAttachments.map {
            attachments.append(contentsOf: $0)
        }

        subpass.depthStencilAttachment.map {
            attachments.append($0)
        }
    }

    func add(dependency: Subpass.Dependency) {
        let sourceIndex: CUnsignedInt
        if let source = dependency.source {
            sourceIndex = CUnsignedInt(indexOfSubpass(appendingIfNotFound: source))
        } else {
            sourceIndex = VK_SUBPASS_EXTERNAL
        }

        let destinationIndex: CUnsignedInt
        if let destination = dependency.destination {
            destinationIndex = CUnsignedInt(indexOfSubpass(appendingIfNotFound: destination))
        } else {
            destinationIndex = VK_SUBPASS_EXTERNAL
        }

        var subpassDependency = VkSubpassDependency()
        subpassDependency.srcSubpass = sourceIndex
        subpassDependency.dstSubpass = destinationIndex
        subpassDependency.srcStageMask = dependency.sourceStage.rawValue
        subpassDependency.srcAccessMask = dependency.sourceAccess.rawValue
        subpassDependency.dstStageMask = dependency.destinationStage.rawValue
        subpassDependency.dstAccessMask = dependency.destinationAccess.rawValue
        subpassDependency.dependencyFlags = dependency.flags.rawValue

        dependencies.append(subpassDependency)
    }
     
    fileprivate func indexOfSubpass(appendingIfNotFound subpass: Subpass) -> Int {
        if let result = subpasses.firstIndex(of: subpass) {
            return result
        } else {
            add(subpass: subpass)

            return subpasses.count - 1
        }
    }

    fileprivate func attachmentsReferences(from attachments: [Attachment]) -> [VkAttachmentReference] {
        return attachments.map { attachment in
            return attachmentsReference(from: attachment)
        }
    }

    fileprivate func attachmentsReference(from attachment: Attachment) -> VkAttachmentReference {
        return VkAttachmentReference(attachment: CUnsignedInt(self.attachments.firstIndex(of: attachment)!), layout: attachment.imageLayout)
    }
}

public final class Subpass {
    public let bindPoint: VkPipelineBindPoint
    public let inputAttachments: [Attachment]?
    public let colorAttachments: [Attachment]?
    public let resolveAttachments: [Attachment]?
    public let depthStencilAttachment: Attachment?
    public let flags: VkSubpassDescriptionFlagBits

    public init(bindPoint: VkPipelineBindPoint,
                inputAttachments: [Attachment]? = nil,
                colorAttachments: [Attachment]? = nil,
                resolveAttachments: [Attachment]? = nil,
                depthStencilAttachment: Attachment? = nil,
                flags: VkSubpassDescriptionFlagBits = []) {
        self.bindPoint = bindPoint
        self.inputAttachments = inputAttachments
        self.colorAttachments = colorAttachments
        self.resolveAttachments = resolveAttachments
        self.depthStencilAttachment = depthStencilAttachment
        self.flags = flags
    }

    public struct Dependency {
        public let source: Subpass?
        public let destination: Subpass?
        public let sourceStage: VkPipelineStageFlagBits
        public let destinationStage: VkPipelineStageFlagBits
        public let sourceAccess: VkAccessFlagBits
        public let destinationAccess: VkAccessFlagBits
        public let flags: VkDependencyFlagBits

        public init(source: Subpass? = nil,
                    destination: Subpass? = nil,
                    sourceStage: VkPipelineStageFlagBits = [],
                    destinationStage: VkPipelineStageFlagBits = [],
                    sourceAccess: VkAccessFlagBits = [],
                    destinationAccess: VkAccessFlagBits = [],
                    flags: VkDependencyFlagBits = []) {
            self.source = source
            self.destination = destination
            self.sourceStage = sourceStage
            self.destinationStage = destinationStage
            self.sourceAccess = sourceAccess
            self.destinationAccess = destinationAccess
            self.flags = flags
        }
    }
}

extension Subpass: Hashable {
    public static func == (lhs: Subpass, rhs: Subpass) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public final class Attachment {
    public let description: VkAttachmentDescription
    public let imageLayout: VkImageLayout

    public init(description: VkAttachmentDescription, imageLayout: VkImageLayout) {
        self.description = description
        self.imageLayout = imageLayout
    }
}

extension Attachment: Equatable {
    public static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        return lhs === rhs
    }
}

fileprivate extension Array where Element == Subpass {
    func withUnsafeSubpassDescriptionBufferPointer<R>(renderPassBuilder: RenderPassBuilder, body: (UnsafeBufferPointer<VkSubpassDescription>) throws -> (R)) throws -> R {
        var buffer = Array<VkSubpassDescription>()
        buffer.reserveCapacity(count)

        return try (self[0..<count]).populateSubpassDescription(renderPassBuilder: renderPassBuilder, buffer: &buffer, body: body)
    }
}

fileprivate extension ArraySlice where Element == Subpass {
    func populateSubpassDescription<R>(renderPassBuilder: RenderPassBuilder, buffer: inout [VkSubpassDescription], body: (UnsafeBufferPointer<VkSubpassDescription>) throws -> (R)) throws -> R {
        let indices = self.indices

        if indices.lowerBound == indices.upperBound {
            return try buffer.withUnsafeBufferPointer {
                return try body($0)
            }
        } else {
            let head = self[indices.lowerBound]

            let inputAttachmentsReferences = head.inputAttachments.map { renderPassBuilder.attachmentsReferences(from: $0) }
            let colorAttachmentsReferences = head.colorAttachments.map { renderPassBuilder.attachmentsReferences(from: $0) }
            let resolveAttachmentsReferences = head.resolveAttachments.map { renderPassBuilder.attachmentsReferences(from: $0) }
            let depthStencilAttachmentsReference: VkAttachmentReference? = head.depthStencilAttachment.map { renderPassBuilder.attachmentsReference(from: $0) }

            return try withUnsafeBufferPointerOrNil(inputAttachmentsReferences) { inputAttachmentsReferences in
                return try withUnsafeBufferPointerOrNil(colorAttachmentsReferences) { colorAttachmentsReferences in
                    return try withUnsafeBufferPointerOrNil(resolveAttachmentsReferences) { resolveAttachmentsReferences in
                        return try depthStencilAttachmentsReference.withUnsafePointerOrNil { depthStencilAttachmentsReference in
                            var subpass = VkSubpassDescription()
                            
                            subpass.pipelineBindPoint = head.bindPoint
                            subpass.flags = head.flags.rawValue
                            
                            inputAttachmentsReferences.map {
                                subpass.inputAttachmentCount = CUnsignedInt($0.count)
                                subpass.pInputAttachments = $0.baseAddress!
                            }

                            colorAttachmentsReferences.map {
                                subpass.colorAttachmentCount = CUnsignedInt($0.count)
                                subpass.pColorAttachments = $0.baseAddress!
                            }

                            subpass.pResolveAttachments = resolveAttachmentsReferences?.baseAddress
                            
                            subpass.pDepthStencilAttachment = depthStencilAttachmentsReference
    
                            buffer.append(subpass)
                            
                            return try (self[indices.dropFirst()]).populateSubpassDescription(renderPassBuilder: renderPassBuilder, buffer: &buffer, body: body)
                        }
                    }
                }
            }
        }
    }
}
