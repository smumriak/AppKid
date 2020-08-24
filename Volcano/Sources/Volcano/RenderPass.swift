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
    public enum GraphError: Error {
        case subpassNotFound(Subpass)
    }

    internal struct Depdendency {
        let source: Subpass
        let destination: Subpass
    }

    var subpasses: [Subpass] = []
    var dependencies: [Depdendency] = []

    public func add(subpass: Subpass) {
        if subpasses.contains(subpass) {
            return
        }

        subpasses.append(subpass)
    }

    public func addDependency(source: Subpass,
                              destination: Subpass,
                              sourceStage: VkPipelineStageFlagBits = .colorAttachmentOutput,
                              destinationStage: VkPipelineStageFlagBits = .colorAttachmentOutput,
                              sourceAccess: VkAccessFlagBits = [],
                              destinationAccess: VkAccessFlagBits = .colorAttachmentWrite,
                              dependencyFlags: VkDependencyFlagBits = []) throws {
//        guard let sourceIndex = subpasses.firstIndex(of: source) else { throw GraphError.subpassNotFound(source) }
//        let destinationIndex = subpasses.firstIndex(of: destination)
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
