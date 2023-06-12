//
//  VulkanStructureChainParser.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2021.
//

import Foundation
import TinyFoundation

public struct VulkanStructureChainParser {
    let values: [VkStructureType: UnsafeRawPointer]

    init(chain: UnsafeRawPointer?) {
        fatalError("Not yet materialized")
        // var nextElement = chain
        // var values: [VkStructureType: UnsafeRawPointer] = [:]

        // while let element = nextElement {
        //     let genericVylkanStructure = GenericVulkanStructureFromChainElement(element)

        //     values[genericVylkanStructure.type] = element

        //     nextElement = genericVylkanStructure.next
        // }

        // self.values = values
    }

    func value<Result: VulkanStructure>() -> Result? {
        if let pointer = values[Result.type] {
            let reboundPointer = pointer.assumingMemoryBound(to: Result.self)

            return reboundPointer.pointee
        } else {
            return nil
        }
    }

    func valueOrNew<Result: VulkanStructure>() -> Result {
        if let result: Result = value() {
            return result
        } else {
            return .new()
        }
    }
}
