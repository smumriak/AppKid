//
//  RenderPass.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2020.
//

import TinyFoundation
import CVulkan

public class RenderPass: VulkanDeviceEntity<SmartPointer<VkRenderPass_T>> {
//    let rootSubpass: Subpass
//
//    init(rootSubpass: Subpass) {
//
//    }
}

public final class SubpassGraph {
    public fileprivate(set) var subpasses: [Subpass] = []
    public fileprivate(set) var dependencies: [VkSubpassDependency] = []

    public func add(subpass: Subpass) {
        if subpasses.contains(subpass) {
            return
        }

        subpasses.append(subpass)
    }

    public func addDependency(source: Subpass?,
                              destination: Subpass,
                              sourceStage: VkPipelineStageFlagBits = .colorAttachmentOutput,
                              destinationStage: VkPipelineStageFlagBits = .colorAttachmentOutput,
                              sourceAccess: VkAccessFlagBits = [],
                              destinationAccess: VkAccessFlagBits = .colorAttachmentWrite,
                              dependencyFlags: VkDependencyFlagBits = []) throws {
        let sourceIndex: CUnsignedInt
        if let source = source {
            sourceIndex = CUnsignedInt(indexOfSubpass(appendingIfNotFound: source))
        } else {
            sourceIndex = VK_SUBPASS_EXTERNAL
        }

        let destinationIndex = CUnsignedInt(indexOfSubpass(appendingIfNotFound: destination))

        var dependency = VkSubpassDependency()
        dependency.srcSubpass = sourceIndex
        dependency.dstSubpass = destinationIndex
        dependency.srcStageMask = sourceStage.rawValue
        dependency.srcAccessMask = sourceAccess.rawValue
        dependency.dstStageMask = destinationStage.rawValue
        dependency.dstAccessMask = destinationAccess.rawValue
        dependency.dependencyFlags = dependencyFlags.rawValue

        dependencies.append(dependency)
    }
     
    fileprivate func indexOfSubpass(appendingIfNotFound subpass: Subpass) -> Int {
        if let result = subpasses.firstIndex(of: subpass) {
            return result
        } else {
            subpasses.append(subpass)

            return subpasses.count - 1
        }
    }
}

public final class Subpass {
    public internal(set) var dependants: [Subpass] = []

    public func addDependancy(on subpass: Subpass) {
        subpass.dependants.append(self)
    }

    internal func traverse(includingSelf: Bool = false, closure: (_ view: Subpass) -> ()) {
        if includingSelf {
            closure(self)
        }

        dependants.forEach {
            $0.traverse(includingSelf: true, closure: closure)
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
