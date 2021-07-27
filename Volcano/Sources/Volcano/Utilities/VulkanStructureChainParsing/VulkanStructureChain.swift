//
//  VulkanStructureChain.swift
//  Volcano
//
//  Created by Serhii Mumriak on 25.07.2021.
//

import TinyFoundation
import CVulkan

public final class VulkanStructureChain<Root: VulkanChainableStructure> {
    var root: Root
    var chainedElements: [VulkanChainableStructure] = []

    init(root: Root) {
        self.root = root
    }

    func add(chainElement: VulkanChainableStructure) {
        chainedElements.append(chainElement)
    }

    func withUnsafeChainPointer<R>(_ body: (UnsafePointer<Root>) throws -> (R)) rethrows -> R {
        var rootCopy = root
        return try chainedElements.withUnsafeChainedElements { last in
            rootCopy.pNext = last
            return try withUnsafePointer(to: &rootCopy) { root in
                try body(root)
            }
        }
    }
}

private extension Array where Element == VulkanChainableStructure {
    func withUnsafeChainedElements<R>(_ body: (UnsafeRawPointer?) throws -> (R)) rethrows -> R {
        if isEmpty {
            return try body(nil)
        }

        let elements: Self = self.reversed()

        let indices = elements.indices

        var head = self[indices.lowerBound]
        let tail = self[indices.dropFirst()]

        return try tail.withUnsafeChainedElements(head: &head, body)
    }
}

private extension ArraySlice where Element == VulkanChainableStructure {
    func withUnsafeChainedElements<R>(head: inout VulkanChainableStructure, _ body: (UnsafeRawPointer) throws -> (R)) rethrows -> R {
        let indices = self.indices

        if indices.lowerBound == indices.upperBound {
            return try head.withUnsafeRawPointer { head in
                return try body(head)
            }
        } else {
            var nextHead = self[indices.lowerBound]
            let tail = self[indices.dropFirst()]

            return try head.withUnsafeRawPointer { head in
                nextHead.pNext = UnsafeRawPointer(head)

                return try tail.withUnsafeChainedElements(head: &nextHead, body)
            }
        }
    }
}
